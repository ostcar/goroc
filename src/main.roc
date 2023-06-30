platform "wasm"
    requires {} { main : Str -> (b -> c) | b has Decoding, c has Encoding }
    exposes []
    packages {
        json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.1.0/xbO9bXdHi7E9ja6upN5EJXpDoYm7lwmJ8VzL7a5zhYE.tar.br",
    }
    imports [
        json.Core.{ jsonWithOptions },
        Decode.{ DecodeResult, fromBytesPartial },
        Encode.{ toBytes },
    ]
    provides [mainForHost]

# # TODO: Make callback (List U8 -> Job) and make Job a enum where one option is just value
# Job : {
#     name: List U8,
#     value: List U8,
#     callback: (List U8 -> List U8),
# }

Job : List U8 -> List U8

mainForHost : List U8 -> Job
mainForHost = \encodedArg ->
    decoded =
        encodedArg
        |> fromBytesPartial (jsonWithOptions { fieldNameMapping: SnakeCase })

    when decoded.result is
        Ok arg ->
            main arg
            |> convertCallback
                    
        Err _ ->
            # {
            #     name: "Error" |> Str.toUtf8,
            #     value:  "Invalid argument" |> toJson,
            #     callback: (\_ -> []) ,
            # }
            \_ -> "Invalid first argument" |> toJson


convertCallback : (b -> c) -> Job | b has Decoding, c has Encoding
convertCallback = \mainCallback ->
    convertedFn : List U8 -> List U8
    convertedFn = \encodedArg ->
        decoded = 
            encodedArg
            |> fromBytesPartial (jsonWithOptions { fieldNameMapping: SnakeCase })

        when decoded.result is
            Ok arg ->
                mainCallback arg
                |> toJson
            
            Err _ ->
                "Invalid second argument" 
                |> toJson

    # {
    #     name: "AAAAAaa" |> toJson,
    #     value: "BBBBB" |> toJson,
    #     callback: convertedFn ,
    # } 
    convertedFn


toJson : a -> List U8 | a has Encoding
toJson = \value -> 
        value
        |> toBytes (jsonWithOptions { fieldNameMapping: SnakeCase })
        |> List.append 0
