%%%-------------------------------------------------------------------
%%% @author oscar toro
%%% @copyright (C) 2015,
%%% @doc
%%%
%%% @end
%%% Created : 11. Feb 2015 18:10
%%%-------------------------------------------------------------------
-module(wc_backend).
-author("oscar").
-vsn('1.0').
-behaviour(gen_server).

%%Includes
-include("../include/diccionario.hrl").
-include_lib("eunit/include/eunit.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
        handle_call/3,
        handle_cast/2,
        handle_info/2,
        terminate/2,
        code_change/3]).

-define(SERVER, ?MODULE).

-export([add_word/2,get_all_words/0]).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
        {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
        gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
        {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
        {stop, Reason :: term()} | ignore).
init([]) ->
        {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
        {reply, Reply :: term(), NewState :: #state{}} |
        {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
        {noreply, NewState :: #state{}} |
        {noreply, NewState :: #state{}, timeout() | hibernate} |
        {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
        {stop, Reason :: term(), NewState :: #state{}}).
handle_call({add_word,WordName,WordDefinition}, _From, State) ->
        Reply = wc_mnesia:add_word(WordName,WordDefinition),
        {reply, Reply, State};
handle_call({get_all_words},_From,State)->
        Reply = wc_mnesia:get_all_words(),
        {reply,Reply,State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
        {noreply, NewState :: #state{}} |
        {noreply, NewState :: #state{}, timeout() | hibernate} |
        {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
        {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
        {noreply, NewState :: #state{}} |
        {noreply, NewState :: #state{}, timeout() | hibernate} |
        {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
        {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
        ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
        {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
        {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

add_word(WordName,Definition) ->
        gen_server:call(?MODULE,{add_word,WordName,Definition}).

get_all_words() ->
        gen_server:call(?MODULE,{get_all_words}).


%% UT

