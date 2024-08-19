extends Node

var args: Array[Arg] = [
  Arg.new({triggers=["-h", "--help", "-?"], help="show this help message and exit", action="store_true"})
]

func _ready() -> void:
  var p := Parser.new()
  for i in args:
    p.add_argument(i)
  var args = p.parse_arguments(OS.get_cmdline_args() + OS.get_cmdline_user_args())
  if args == null:
    get_tree().quit()
  elif args.get("help", false):
    print(p.help())
    get_tree().quit()
