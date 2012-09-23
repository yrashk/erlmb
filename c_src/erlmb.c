#include "erl_nif.h"

#include <string.h>

// Prototypes
static ERL_NIF_TERM erlmb_write(ErlNifEnv* env, int argc,
                                   const ERL_NIF_TERM argv[]);

static ErlNifFunc nif_funcs[] =
{
    {"do_write", 4, erlmb_write},
};

static ERL_NIF_TERM erlmb_write(ErlNifEnv* env, int argc,
                                   const ERL_NIF_TERM argv[])
{
    // verify is first argument is a binary
    if (!enif_is_binary(env, argv[0])) {
        return enif_make_badarg(env);
    }

    // Extract the binary
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    // Figure out offset and value length
    int offset, length;
    enif_get_int(env, argv[2], &offset);
    enif_get_int(env, argv[3], &length);

    if (enif_is_binary(env, argv[1])) {
        // binaries are totally fine
        ErlNifBinary value_bin;
        enif_inspect_binary(env, argv[1], &value_bin);
        memcpy(bin.data + offset, value_bin.data, length);
    } else  {
        return enif_make_badarg(env);
    }

    return argv[0];
}


static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    return 0;
}

ERL_NIF_INIT(erlmb, nif_funcs, &on_load, NULL, NULL, NULL);
