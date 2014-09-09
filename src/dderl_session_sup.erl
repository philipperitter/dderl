-module(dderl_session_sup).

-behaviour(supervisor).

%% API
-export([start_link/0
        ,start_session/2
        ,close_session/1
        ,list_sessions/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I), {I, {I, start_link, []}, temporary, 5000, worker, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================
-spec start_link() -> ignore | {error, term()} | {ok, pid()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

-spec start_session(reference(), binary()) -> {error, term()} | {ok, pid()}.
start_session(Ref, RandBytes) ->
	supervisor:start_child(?MODULE, [Ref, RandBytes]).

-spec close_session(pid()) -> ok | {error, not_found | simple_one_for_one}.
close_session(SessionPid) ->
    supervisor:terminate_child(?MODULE, SessionPid).

-spec list_sessions() -> list().
list_sessions() ->
    %%TODO: We should return more information, maybe ip and username.
    supervisor:which_children(?MODULE).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	SupFlags = {simple_one_for_one, 5, 10},
    {ok, {SupFlags, [?CHILD(dderl_session)]}}.