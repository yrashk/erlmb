-module(erlmb).

%% Public
-export([write/4]).

-on_load(init/0).

-define(nif_stub, nif_stub_error(?LINE)).
nif_stub_error(Line) ->
    erlang:nif_error({nif_not_loaded,module,?MODULE,line,Line}).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

init() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, bad_name} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Path ->
                      Path
              end,
    erlang:load_nif(filename:join(PrivDir, ?MODULE), 0).

%% ===================================================================
%% Public
%% ===================================================================

write(Binary, Value, Offset, Length) when is_integer(Value) ->
    write(Binary, <<Value:(Length * 8)>>, Offset, Length);

write(Binary, Value, Offset, Length) ->
    do_write(Binary, Value, Offset, Length).

do_write(_Binary, _Value, _Offset, _Length)  ->
    ?nif_stub.

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

write_byte_test() ->
  Binary = <<0,1,2,3>>,
  write(Binary, <<-1>>, 1, 1),
  ?assertEqual(<<0,-1,2,3>>, Binary).

write_multiple_byte_test() ->
  Binary = <<1,1,2,3>>,
  write(Binary, <<-2,-1>>, 1, 2),
  ?assertEqual(<<1,-2,-1,3>>, Binary).

write_integer_test() ->
  Binary = <<2,1,2,3>>,
  write(Binary, -1, 1, 1),
  ?assertEqual(<<2,-1,2,3>>, Binary).

-endif.
