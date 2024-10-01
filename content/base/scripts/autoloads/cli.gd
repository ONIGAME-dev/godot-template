extends Node

var arguments: Array[Arg] = [
  Arg.new({triggers=["-h", "--help", "-?"], help="show this help message and exit", action="store_true"})
]

func _ready() -> void:
  var _parser := Parser.new()
  for i in arguments:
    _parser.add_argument(i)
  var _args = _parser.parse_arguments(OS.get_cmdline_args() + OS.get_cmdline_user_args())
  if _args == null:
    get_tree().quit()
  elif _args.get("help", false):
    print(_parser.help())
    get_tree().quit()
