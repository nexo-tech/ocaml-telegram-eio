type field = {
  name : string;
  typ : string;
  optional : bool;
  description : string;
}

type tdef = {
  anchor : string;
  title : string;
  fields : field list;
}

val pp_field : field -> string
val pp_tdef : tdef -> string

type mdef = {
  m_anchor : string;
  m_name : string;
  returns : string option;
  params : field list;
}

val pp_mdef : mdef -> string
