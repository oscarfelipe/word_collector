%% -*- coding: utf-8 -*-
-module(wc_json).
-export([encode/1,decode/1,record_to_proplist/1]).

-include_lib("eunit/include/eunit.hrl").
-include("../include/diccionario.hrl").

-ifdef(debug_flag).
-define(DEBUG(X),io:format("DEBUG ~p: ~p ~p~n",[?MODULE,?LINE,X])).
-else.
-define(DEBUG(X),void).
-endif.


%% Encode Word or Language records to JSON
%%
-spec encode(#wc_word{} | [#wc_word{}]) -> binary().
encode(#wc_word{} = Rec) ->  
  jiffy:encode({[{word,{record_to_proplist(Rec)}}]});

encode(#wc_language{} = Rec) ->
  jiffy:encode({[{language,{record_to_proplist(Rec)}}]});

%% endcode lists of words
encode(Ls)-> 
  Head = hd(Ls),

  if is_record(Head,wc_word) ->
    encode_list_of_words(Ls);
  true -> %read it as else 
    encode_list_of_langs(Ls)
  end.

encode_list_of_words(Ls)->
  Words = [{record_to_proplist(W)}|| W <- Ls],
  jiffy:encode({[{words,Words}]}).

encode_list_of_langs(Ls) ->
  Langs = [{record_to_proplist(L)}|| L <- Ls],
  jiffy:encode({[{languages,Langs}]}).

%% Decode Json Binaries to wc_words or wc_languages
%% 
-spec decode(binary()) ->#wc_word{} | #wc_language{} | 
  [#wc_word{}] | [#wc_language{}].

decode(Bin) ->
  {Decoded} = jiffy:decode(Bin),
  [{Type,ToDecode}] = Decoded,
  
  case Type  of
  <<"word">>  -> 
    {TD} = ToDecode,
    one_record_decoder(TD,lists:seq(2,11),#wc_word{});
  <<"words">> -> 
    list_of_records_decoder(ToDecode);
  <<"language">>  ->
   {TD} = ToDecode,
    one_record_decoder(TD,lists:seq(2,4),#wc_language{});
  <<"languages">> -> 
    list_of_records_decoder(ToDecode)
  end.

%% Auxiliar funtion that performs decoding of PropList.
%% Takes a Properlist with key/values of the record(PL)
%% A List of numbers with indexes of the record(L) 
%% And the record itself. Returns a record.
%% The Index 1 of a record is the record's name,
%% that is why the Indexes starts at 2, which is the first
%% value of the record.	  
one_record_decoder(PL,L, Rec) ->
 
  Values    = [V ||  {_K,V} <- PL], % all the values
  Formated  = lists:zip(L,Values), % proplist{int,binary() | []}
  lists:foldr(fun({K,V},Acc) -> setelement(K,Acc,V) end,Rec,Formated). 

list_of_records_decoder(TD) ->
  ?DEBUG(TD),
  PLs = [PL || {PL} <-TD],
  [one_record_decoder(PL,lists:seq(2,11),#wc_word{}) ||
    PL <- PLs].
  
    
-spec record_to_proplist(#wc_word{}) -> [{atom(),any()}].
record_to_proplist(#wc_word{} = Rec) ->
  lists:zip(record_info(fields,wc_word),   
  tl(tuple_to_list(Rec)));

record_to_proplist(#wc_language{} = Rec) ->
  lists:zip(record_info(fields,wc_language),
  tl(tuple_to_list(Rec))).



%%%%%%%%%%%%%%%%%%%
%%%%%%%TEST%%%%%%%%
%%%%%%%%%%%%%%%%%%%
encode_decode_word_test() ->

  W = #wc_word{title = <<"numse">>, definition = <<"popin">>},
  Encoded = encode(W),
  W2 = decode(Encoded),
  ?assert(<<"numse">> =:= W2#wc_word.title),     
  ?assert(<<"popin">> =:= W2#wc_word.definition).
    
encode_decode_language_test() ->
  [L,L2] = two_languages(),

  Encoded = encode(L),
  Decoded = decode(Encoded), 

  Encoded2 = encode(L2),
  Decoded2 = decode(Encoded2),
  
  ?assert(<<"español"/utf8>> =:= Decoded#wc_language.name),
  ?assert(<<"spanish">>      =:= Decoded2#wc_language.name).

encode_decode_words_test() ->
  W1 = #wc_word{title = <<"flink">>, definition = <<"amable">>},
  W2 = #wc_word{title = <<"sød"/utf8>>, definition = <<"dulce">>},
 
  Encoded = encode([W1,W2]),
  Decoded = decode(Encoded),

  ?assert([W1,W2] =:= Decoded).

encode_decode_languages_test() ->
    Ls = two_languages(),  

    LsEncoded = wc_json:encode(Ls),
    LsDecoded = wc_json:decode(LsEncoded),

    ?assert(Ls =:= LsDecoded).


two_languages() ->
  L  = #wc_language{name = <<"español"/utf8>>, initials = <<"es">>, is_mother_language = true},
  L2 = #wc_language{name = <<"spanish"/utf8>>, initials = <<"sp">>, is_mother_language = true},
  [L,L2].
