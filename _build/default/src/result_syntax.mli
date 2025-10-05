val ( let* ) : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
val ( let+ ) : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result
