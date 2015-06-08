-module(snake).
-behaviour(gen_server).
-compile([export_all]).
-record(state,{direct,roads=[],snake=[]}).
-define(SPEED,300).
-define(WIDTH,30).
-define(HEIGHT,10).

start() ->
    {ok,Pid} = ?MODULE:start_link(),
    spawn(?MODULE,moveon,[Pid]),
    readKey(Pid).

readKey(Pid)->
    case is_process_alive(Pid) of
        true->
            A = io:get_chars("chars:",1),
            Pid ! {key,A},
            readKey(Pid);
        _->
            ok
    end.

start_link()->
    gen_server:start_link(?MODULE,[],[]).

init([])->
    Roads = [{"0",1},{"0",2},{"D",3}],
    Roads2 = lists:append(Roads,lists:map(fun(I)-> {"-",I} end,lists:seq(4,?WIDTH*?HEIGHT))),
    Roads3 = randomFood(Roads2),
    Sanke = [{0,1},{0,2},{0,3}],
    {ok,#state{direct=right,roads=Roads3,snake=Sanke}}.

handle_call({internal, Cmd, Args}, _From, State) ->
    {Ret, State1}  = erlang:apply(?MODULE, Cmd, [Args, State]),
    {reply, Ret, State1};
handle_call(_Request, _From, State) ->
    {reply, not_support, State}.

handle_info({key,"a"},#state{direct=Direct}=State)->
    case Direct of
        down->
            {noreply,State#state{direct=left}};
        up->
            {noreply,State#state{direct=left}};
        _->
            {noreply,State}
    end;

handle_info({key,"d"},#state{direct=Direct}=State)->
    case Direct of
        down->
            {noreply,State#state{direct=right}};
        up->
            {noreply,State#state{direct=right}};
        _->
            {noreply,State}
    end;

handle_info({key,"w"},#state{direct=Direct}=State)->
    case Direct of
        left->
            {noreply,State#state{direct=up}};
        right->
            {noreply,State#state{direct=up}};
        _->
            {noreply,State}
    end;

handle_info({key,"s"},#state{direct=Direct}=State)->
    case Direct of
        left->
            {noreply,State#state{direct=down}};
        right->
            {noreply,State#state{direct=down}};
        _->
            {noreply,State}
    end;

handle_info({key,"q"},State)->
    {stop,normal,State};
handle_info(_,State)->
    {noreply,State}.
terminate(_Reason, _State) -> ok.

clear() -> io:format("\033[1;1H\033[2J").

randomFood(Roads) ->
    Temp = lists:foldl(
             fun ({X,I},Temp) -> 
                case X of
                    "-"->
                        lists:append(Temp,[I]);
                    _->
                        Temp
                end
             end
     ,[],Roads),
    Random = lists:nth(random:uniform(length(Temp)),Temp),
    lists:keyreplace(Random,2,Roads,{"I",Random}).

moveon(Pid)->
    gen_server:call(Pid, {internal, doMoveon, []}, infinity).

doMoveon([],#state{direct=Direct,roads=Roads,snake=Snake} = State)->
    {Tail,Body} = lists:split(1,Snake),
    {Row,Col} = lists:last(Snake),
    {Row2,Col2} = Head = case Direct of
        up->
           case Row of
               0 ->
                   {?HEIGHT-1,Col};
               _->
                   {Row-1,Col}
           end;
        down->
            case Row of
                ?HEIGHT-1->
                    {0,Col};
                _->
                    {Row+1,Col}
            end;
        left->
            case Col of
                1 ->
                    {Row,?WIDTH};
                _->
                    {Row,Col-1}
            end;
        right->
            case Col of
                ?WIDTH ->
                    {Row,1};
                 _->
                    {Row,Col+1}
            end
        end,
    Snake2 = lists:append(Body,[Head]),
    {Snake4,{Roads3,IsRun}} = 
        case lists:nth(Row2*?WIDTH+Col2,Roads) of
        {"I",_}->
            Snake3 = lists:append([Tail],Snake2),
            Roads2 = updateSnake(Roads,Snake3),
            {Snake3,randomFood(Roads2)};
        _->
            {Snake2,updateSnake(Roads,Snake2)} 
        end,
    %clear(),
    printBorad(Roads),
    case IsRun of
        true->
            timer:sleep(?SPEED),
            spawn(?MODULE,moveon,[self()]),
            {noreply, State#state{roads=Roads3,snake=Snake4}};
        _->
            io:format("isrun:~p~n",[IsRun]),
            {stop,State}
    end.

updateSnake(Roads,Snake)->
    Roads2 = lists:map(
                fun({X,I})->
                    case X of
                        "I"->
                            {"I",I};
                        _->
                            {"-",I}
                    end
                end,Roads),
    Roads3 = lists:foldl(
               fun({Row,Col},Temp)->
                       I = Row*?WIDTH + Col,
                       lists:keyreplace(I,2,Temp,{"0",I})
               end,Roads2,lists:sublist(Snake,1,length(Snake)-1)),
    {Row,Col} = lists:last(Snake),
    Head = Row*?WIDTH + Col,
    case lists:keyfind(Head,2,Roads3) of
        {"0",_}->
            {Roads3,false};
        _->
            {lists:keyreplace(Head,2,Roads3,{"D",Head}),true}
    end.

printBorad(Roads)->
    clear(),
    lists:foreach(
      fun({Piece,I})->
        io:format(getColor(Piece)++Piece),
        case I rem ?WIDTH of
            0->
                io:format("~n");
            _->
                ok
        end
      end,Roads),
    io:format("\33[m").


getColor("-")->
    "\33[1;33m";%Road Yellow
getColor("D")->
    "\33[1;36m";%Head Cyan
getColor("0")->
    "\33[1;35m";%Body Magenta
getColor("I")->
    "\33[1;34m".%Food Blue
