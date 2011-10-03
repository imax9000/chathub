-module(chathub).
-behaviour(supervisor).
-behaviour(application).

-export([start/2, init/1, stop/1]).

start(_StartType, _Args) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, true).

stop(_) ->
    ok.

init(true) ->
    Config = load_config(),
    Childs = start_hubs(Config),
    {ok, {{one_for_one, 10, 3}, Childs}}.

load_config() ->
    File = get_config_path(),
    case file:consult(File) of
	{ok, Terms} ->
	    Terms;
	{error, {_, _, _} = Error} ->
	    error_logger:error_msg("Unable to load config file ~s:~n~s",
		[File, file:format_error(Error)]),
	    exit(unable_to_parse_config);
	{error, Error} ->
	    error_logger:error_msg("Unable to open config file ~s: ~p",
		[File, Error]),
	    exit(unable_to_open_config)
    end.

start_hubs(Config) ->
    [].

get_config_path() ->
    case application:get_env(config) of
	{ok, Path} ->
	    Path;
	undefined ->
	    case os:getenv("CHATHUB_CONFIG") of
		false ->
		    "chathub.cfg";
		Path ->
		    Path
	    end
    end.
