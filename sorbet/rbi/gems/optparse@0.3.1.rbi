# typed: false

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `optparse` gem.
# Please instead update this file by running `bin/tapioca gem optparse`.

# --
# == Developer Documentation (not for RDoc output)
#
# === Class tree
#
# - OptionParser:: front end
# - OptionParser::Switch:: each switches
# - OptionParser::List:: options list
# - OptionParser::ParseError:: errors on parsing
#   - OptionParser::AmbiguousOption
#   - OptionParser::NeedlessArgument
#   - OptionParser::MissingArgument
#   - OptionParser::InvalidOption
#   - OptionParser::InvalidArgument
#     - OptionParser::AmbiguousArgument
#
# === Object relationship diagram
#
#   +--------------+
#   | OptionParser |<>-----+
#   +--------------+       |                      +--------+
#                          |                    ,-| Switch |
#        on_head -------->+---------------+    /  +--------+
#        accept/reject -->| List          |<|>-
#                         |               |<|>-  +----------+
#        on ------------->+---------------+    `-| argument |
#                           :           :        |  class   |
#                         +---------------+      |==========|
#        on_tail -------->|               |      |pattern   |
#                         +---------------+      |----------|
#   OptionParser.accept ->| DefaultList   |      |converter |
#                reject   |(shared between|      +----------+
#                         | all instances)|
#                         +---------------+
#
# ++
#
# == OptionParser
#
# === New to \OptionParser?
#
# See the {Tutorial}[optparse/tutorial.rdoc].
#
# === Introduction
#
# OptionParser is a class for command-line option analysis.  It is much more
# advanced, yet also easier to use, than GetoptLong, and is a more Ruby-oriented
# solution.
#
# === Features
#
# 1. The argument specification and the code to handle it are written in the
#    same place.
# 2. It can output an option summary; you don't need to maintain this string
#    separately.
# 3. Optional and mandatory arguments are specified very gracefully.
# 4. Arguments can be automatically converted to a specified class.
# 5. Arguments can be restricted to a certain set.
#
# All of these features are demonstrated in the examples below.  See
# #make_switch for full documentation.
#
# === Minimal example
#
#   require 'optparse'
#
#   options = {}
#   OptionParser.new do |parser|
#     parser.banner = "Usage: example.rb [options]"
#
#     parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#       options[:verbose] = v
#     end
#   end.parse!
#
#   p options
#   p ARGV
#
# === Generating Help
#
# OptionParser can be used to automatically generate help for the commands you
# write:
#
#   require 'optparse'
#
#   Options = Struct.new(:name)
#
#   class Parser
#     def self.parse(options)
#       args = Options.new("world")
#
#       opt_parser = OptionParser.new do |parser|
#         parser.banner = "Usage: example.rb [options]"
#
#         parser.on("-nNAME", "--name=NAME", "Name to say hello to") do |n|
#           args.name = n
#         end
#
#         parser.on("-h", "--help", "Prints this help") do
#           puts parser
#           exit
#         end
#       end
#
#       opt_parser.parse!(options)
#       return args
#     end
#   end
#   options = Parser.parse %w[--help]
#
#   #=>
#      # Usage: example.rb [options]
#      #     -n, --name=NAME                  Name to say hello to
#      #     -h, --help                       Prints this help
#
# === Required Arguments
#
# For options that require an argument, option specification strings may include an
# option name in all caps. If an option is used without the required argument,
# an exception will be raised.
#
#   require 'optparse'
#
#   options = {}
#   OptionParser.new do |parser|
#     parser.on("-r", "--require LIBRARY",
#               "Require the LIBRARY before executing your script") do |lib|
#       puts "You required #{lib}!"
#     end
#   end.parse!
#
# Used:
#
#   $ ruby optparse-test.rb -r
#   optparse-test.rb:9:in `<main>': missing argument: -r (OptionParser::MissingArgument)
#   $ ruby optparse-test.rb -r my-library
#   You required my-library!
#
# === Type Coercion
#
# OptionParser supports the ability to coerce command line arguments
# into objects for us.
#
# OptionParser comes with a few ready-to-use kinds of  type
# coercion. They are:
#
# - Date  -- Anything accepted by +Date.parse+
# - DateTime -- Anything accepted by +DateTime.parse+
# - Time -- Anything accepted by +Time.httpdate+ or +Time.parse+
# - URI  -- Anything accepted by +URI.parse+
# - Shellwords -- Anything accepted by +Shellwords.shellwords+
# - String -- Any non-empty string
# - Integer -- Any integer. Will convert octal. (e.g. 124, -3, 040)
# - Float -- Any float. (e.g. 10, 3.14, -100E+13)
# - Numeric -- Any integer, float, or rational (1, 3.4, 1/3)
# - DecimalInteger -- Like +Integer+, but no octal format.
# - OctalInteger -- Like +Integer+, but no decimal format.
# - DecimalNumeric -- Decimal integer or float.
# - TrueClass --  Accepts '+, yes, true, -, no, false' and
#   defaults as +true+
# - FalseClass -- Same as +TrueClass+, but defaults to +false+
# - Array -- Strings separated by ',' (e.g. 1,2,3)
# - Regexp -- Regular expressions. Also includes options.
#
# We can also add our own coercions, which we will cover below.
#
# ==== Using Built-in Conversions
#
# As an example, the built-in +Time+ conversion is used. The other built-in
# conversions behave in the same way.
# OptionParser will attempt to parse the argument
# as a +Time+. If it succeeds, that time will be passed to the
# handler block. Otherwise, an exception will be raised.
#
#   require 'optparse'
#   require 'optparse/time'
#   OptionParser.new do |parser|
#     parser.on("-t", "--time [TIME]", Time, "Begin execution at given time") do |time|
#       p time
#     end
#   end.parse!
#
# Used:
#
#   $ ruby optparse-test.rb  -t nonsense
#   ... invalid argument: -t nonsense (OptionParser::InvalidArgument)
#   $ ruby optparse-test.rb  -t 10-11-12
#   2010-11-12 00:00:00 -0500
#   $ ruby optparse-test.rb  -t 9:30
#   2014-08-13 09:30:00 -0400
#
# ==== Creating Custom Conversions
#
# The +accept+ method on OptionParser may be used to create converters.
# It specifies which conversion block to call whenever a class is specified.
# The example below uses it to fetch a +User+ object before the +on+ handler receives it.
#
#   require 'optparse'
#
#   User = Struct.new(:id, :name)
#
#   def find_user id
#     not_found = ->{ raise "No User Found for id #{id}" }
#     [ User.new(1, "Sam"),
#       User.new(2, "Gandalf") ].find(not_found) do |u|
#       u.id == id
#     end
#   end
#
#   op = OptionParser.new
#   op.accept(User) do |user_id|
#     find_user user_id.to_i
#   end
#
#   op.on("--user ID", User) do |user|
#     puts user
#   end
#
#   op.parse!
#
# Used:
#
#   $ ruby optparse-test.rb --user 1
#   #<struct User id=1, name="Sam">
#   $ ruby optparse-test.rb --user 2
#   #<struct User id=2, name="Gandalf">
#   $ ruby optparse-test.rb --user 3
#   optparse-test.rb:15:in `block in find_user': No User Found for id 3 (RuntimeError)
#
# === Store options to a Hash
#
# The +into+ option of +order+, +parse+ and so on methods stores command line options into a Hash.
#
#   require 'optparse'
#
#   options = {}
#   OptionParser.new do |parser|
#     parser.on('-a')
#     parser.on('-b NUM', Integer)
#     parser.on('-v', '--verbose')
#   end.parse!(into: options)
#
#   p options
#
# Used:
#
#   $ ruby optparse-test.rb -a
#   {:a=>true}
#   $ ruby optparse-test.rb -a -v
#   {:a=>true, :verbose=>true}
#   $ ruby optparse-test.rb -a -b 100
#   {:a=>true, :b=>100}
#
# === Complete example
#
# The following example is a complete Ruby program.  You can run it and see the
# effect of specifying various options.  This is probably the best way to learn
# the features of +optparse+.
#
#   require 'optparse'
#   require 'optparse/time'
#   require 'ostruct'
#   require 'pp'
#
#   class OptparseExample
#     Version = '1.0.0'
#
#     CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
#     CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }
#
#     class ScriptOptions
#       attr_accessor :library, :inplace, :encoding, :transfer_type,
#                     :verbose, :extension, :delay, :time, :record_separator,
#                     :list
#
#       def initialize
#         self.library = []
#         self.inplace = false
#         self.encoding = "utf8"
#         self.transfer_type = :auto
#         self.verbose = false
#       end
#
#       def define_options(parser)
#         parser.banner = "Usage: example.rb [options]"
#         parser.separator ""
#         parser.separator "Specific options:"
#
#         # add additional options
#         perform_inplace_option(parser)
#         delay_execution_option(parser)
#         execute_at_time_option(parser)
#         specify_record_separator_option(parser)
#         list_example_option(parser)
#         specify_encoding_option(parser)
#         optional_option_argument_with_keyword_completion_option(parser)
#         boolean_verbose_option(parser)
#
#         parser.separator ""
#         parser.separator "Common options:"
#         # No argument, shows at tail.  This will print an options summary.
#         # Try it and see!
#         parser.on_tail("-h", "--help", "Show this message") do
#           puts parser
#           exit
#         end
#         # Another typical switch to print the version.
#         parser.on_tail("--version", "Show version") do
#           puts Version
#           exit
#         end
#       end
#
#       def perform_inplace_option(parser)
#         # Specifies an optional option argument
#         parser.on("-i", "--inplace [EXTENSION]",
#                   "Edit ARGV files in place",
#                   "(make backup if EXTENSION supplied)") do |ext|
#           self.inplace = true
#           self.extension = ext || ''
#           self.extension.sub!(/\A\.?(?=.)/, ".")  # Ensure extension begins with dot.
#         end
#       end
#
#       def delay_execution_option(parser)
#         # Cast 'delay' argument to a Float.
#         parser.on("--delay N", Float, "Delay N seconds before executing") do |n|
#           self.delay = n
#         end
#       end
#
#       def execute_at_time_option(parser)
#         # Cast 'time' argument to a Time object.
#         parser.on("-t", "--time [TIME]", Time, "Begin execution at given time") do |time|
#           self.time = time
#         end
#       end
#
#       def specify_record_separator_option(parser)
#         # Cast to octal integer.
#         parser.on("-F", "--irs [OCTAL]", OptionParser::OctalInteger,
#                   "Specify record separator (default \\0)") do |rs|
#           self.record_separator = rs
#         end
#       end
#
#       def list_example_option(parser)
#         # List of arguments.
#         parser.on("--list x,y,z", Array, "Example 'list' of arguments") do |list|
#           self.list = list
#         end
#       end
#
#       def specify_encoding_option(parser)
#         # Keyword completion.  We are specifying a specific set of arguments (CODES
#         # and CODE_ALIASES - notice the latter is a Hash), and the user may provide
#         # the shortest unambiguous text.
#         code_list = (CODE_ALIASES.keys + CODES).join(', ')
#         parser.on("--code CODE", CODES, CODE_ALIASES, "Select encoding",
#                   "(#{code_list})") do |encoding|
#           self.encoding = encoding
#         end
#       end
#
#       def optional_option_argument_with_keyword_completion_option(parser)
#         # Optional '--type' option argument with keyword completion.
#         parser.on("--type [TYPE]", [:text, :binary, :auto],
#                   "Select transfer type (text, binary, auto)") do |t|
#           self.transfer_type = t
#         end
#       end
#
#       def boolean_verbose_option(parser)
#         # Boolean switch.
#         parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#           self.verbose = v
#         end
#       end
#     end
#
#     #
#     # Return a structure describing the options.
#     #
#     def parse(args)
#       # The options specified on the command line will be collected in
#       # *options*.
#
#       @options = ScriptOptions.new
#       @args = OptionParser.new do |parser|
#         @options.define_options(parser)
#         parser.parse!(args)
#       end
#       @options
#     end
#
#     attr_reader :parser, :options
#   end  # class OptparseExample
#
#   example = OptparseExample.new
#   options = example.parse(ARGV)
#   pp options # example.options
#   pp ARGV
#
# === Shell Completion
#
# For modern shells (e.g. bash, zsh, etc.), you can use shell
# completion for command line options.
#
# === Further documentation
#
# The above examples, along with the accompanying
# {Tutorial}[optparse/tutorial.rdoc],
# should be enough to learn how to use this class.
# If you have any questions, file a ticket at http://bugs.ruby-lang.org.
class OptionParser
  # Initializes the instance and yields itself if called with a block.
  #
  # +banner+:: Banner message.
  # +width+::  Summary width.
  # +indent+:: Summary indent.
  #
  # @return [OptionParser] a new instance of OptionParser
  # @yield [_self]
  # @yieldparam _self [OptionParser] the object that the method was called on
  #
  # source://optparse//optparse.rb#1143
  def initialize(banner = T.unsafe(nil), width = T.unsafe(nil), indent = T.unsafe(nil)); end

  # source://optparse//optparse.rb#1291
  def abort(mesg = T.unsafe(nil)); end

  # Directs to accept specified class +t+. The argument string is passed to
  # the block in which it should be converted to the desired class.
  #
  # +t+::   Argument class specifier, any object including Class.
  # +pat+:: Pattern for argument, defaults to +t+ if it responds to match.
  #
  #   accept(t, pat, &block)
  #
  # source://optparse//optparse.rb#1186
  def accept(*args, &blk); end

  # source://optparse//optparse.rb#1156
  def add_officious; end

  # Returns additional info.
  #
  # source://optparse//optparse.rb#1864
  def additional_message(typ, opt); end

  # Heading banner preceding summary.
  #
  # source://optparse//optparse.rb#1235
  def banner; end

  # Heading banner preceding summary.
  #
  # source://optparse//optparse.rb#1210
  def banner=(_arg0); end

  # Subject of #on_tail.
  #
  # source://optparse//optparse.rb#1305
  def base; end

  # source://optparse//optparse.rb#1875
  def candidate(word); end

  # source://optparse//optparse.rb#1032
  def compsys(to, name = T.unsafe(nil)); end

  # :call-seq:
  #   define_head(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1561
  def def_head_option(*opts, &block); end

  # :call-seq:
  #   define(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1540
  def def_option(*opts, &block); end

  # :call-seq:
  #   define_tail(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1584
  def def_tail_option(*opts, &block); end

  # Strings to be parsed in default.
  #
  # source://optparse//optparse.rb#1223
  def default_argv; end

  # Strings to be parsed in default.
  #
  # source://optparse//optparse.rb#1223
  def default_argv=(_arg0); end

  # :call-seq:
  #   define(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1540
  def define(*opts, &block); end

  # :call-seq:
  #   define_head(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1561
  def define_head(*opts, &block); end

  # :call-seq:
  #   define_tail(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1584
  def define_tail(*opts, &block); end

  # Parses environment variable +env+ or its uppercase with splitting like a
  # shell.
  #
  # +env+ defaults to the basename of the program.
  #
  # source://optparse//optparse.rb#1948
  def environment(env = T.unsafe(nil)); end

  # Wrapper method for getopts.rb.
  #
  #   params = ARGV.getopts("ab:", "foo", "bar:", "zot:Z;zot option")
  #   # params["a"] = true   # -a
  #   # params["b"] = "1"    # -b1
  #   # params["foo"] = "1"  # --foo
  #   # params["bar"] = "x"  # --bar x
  #   # params["zot"] = "z"  # --zot Z
  #
  # source://optparse//optparse.rb#1778
  def getopts(*args); end

  # Returns option summary string.
  #
  # source://optparse//optparse.rb#1347
  def help; end

  # source://optparse//optparse.rb#1132
  def inc(*args); end

  # source://optparse//optparse.rb#1368
  def inspect; end

  # Loads options from file names as +filename+. Does nothing when the file
  # is not present. Returns whether successfully loaded.
  #
  # +filename+ defaults to basename of the program without suffix in a
  # directory ~/.options, then the basename with '.options' suffix
  # under XDG and Haiku standard places.
  #
  # The optional +into+ keyword argument works exactly like that accepted in
  # method #parse.
  #
  # source://optparse//optparse.rb#1916
  def load(filename = T.unsafe(nil), into: T.unsafe(nil)); end

  # :call-seq:
  #   make_switch(params, block = nil)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1402
  def make_switch(opts, block = T.unsafe(nil)); end

  # Pushes a new List.
  #
  # source://optparse//optparse.rb#1312
  def new; end

  # :call-seq:
  #   on(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # source://optparse//optparse.rb#1550
  def on(*opts, &block); end

  # :call-seq:
  #   on_head(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # The new option is added at the head of the summary.
  #
  # source://optparse//optparse.rb#1573
  def on_head(*opts, &block); end

  # :call-seq:
  #   on_tail(*params, &block)
  #
  # :include: ../doc/optparse/creates_option.rdoc
  #
  # The new option is added at the tail of the summary.
  #
  # source://optparse//optparse.rb#1597
  def on_tail(*opts, &block); end

  # Parses command line arguments +argv+ in order. When a block is given,
  # each non-option argument is yielded. When optional +into+ keyword
  # argument is provided, the parsed option values are stored there via
  # <code>[]=</code> method (so it can be Hash, or OpenStruct, or other
  # similar object).
  #
  # Returns the rest of +argv+ left unparsed.
  #
  # source://optparse//optparse.rb#1619
  def order(*argv, into: T.unsafe(nil), &nonopt); end

  # Same as #order, but removes switches destructively.
  # Non-option arguments remain in +argv+.
  #
  # source://optparse//optparse.rb#1628
  def order!(argv = T.unsafe(nil), into: T.unsafe(nil), &nonopt); end

  # Parses command line arguments +argv+ in order when environment variable
  # POSIXLY_CORRECT is set, and in permutation mode otherwise.
  # When optional +into+ keyword argument is provided, the parsed option
  # values are stored there via <code>[]=</code> method (so it can be Hash,
  # or OpenStruct, or other similar object).
  #
  # source://optparse//optparse.rb#1751
  def parse(*argv, into: T.unsafe(nil)); end

  # Same as #parse, but removes switches destructively.
  # Non-option arguments remain in +argv+.
  #
  # source://optparse//optparse.rb#1760
  def parse!(argv = T.unsafe(nil), into: T.unsafe(nil)); end

  # Parses command line arguments +argv+ in permutation mode and returns
  # list of non-option arguments. When optional +into+ keyword
  # argument is provided, the parsed option values are stored there via
  # <code>[]=</code> method (so it can be Hash, or OpenStruct, or other
  # similar object).
  #
  # source://optparse//optparse.rb#1728
  def permute(*argv, into: T.unsafe(nil)); end

  # Same as #permute, but removes switches destructively.
  # Non-option arguments remain in +argv+.
  #
  # source://optparse//optparse.rb#1737
  def permute!(argv = T.unsafe(nil), into: T.unsafe(nil)); end

  # source://optparse//optparse.rb#1350
  def pretty_print(q); end

  # Program name to be emitted in error message and default banner, defaults
  # to $0.
  #
  # source://optparse//optparse.rb#1247
  def program_name; end

  # Program name to be emitted in error message and default banner,
  # defaults to $0.
  #
  # source://optparse//optparse.rb#1214
  def program_name=(_arg0); end

  # Whether to raise at unknown option.
  #
  # source://optparse//optparse.rb#1230
  def raise_unknown; end

  # Whether to raise at unknown option.
  #
  # source://optparse//optparse.rb#1230
  def raise_unknown=(_arg0); end

  # Directs to reject specified class argument.
  #
  # +t+:: Argument class specifier, any object including Class.
  #
  #   reject(t)
  #
  # source://optparse//optparse.rb#1199
  def reject(*args, &blk); end

  # Release code
  #
  # source://optparse//optparse.rb#1272
  def release; end

  # Release code
  #
  # source://optparse//optparse.rb#1260
  def release=(_arg0); end

  # Removes the last List.
  #
  # source://optparse//optparse.rb#1324
  def remove; end

  # Whether to require that options match exactly (disallows providing
  # abbreviated long option as short option).
  #
  # source://optparse//optparse.rb#1227
  def require_exact; end

  # Whether to require that options match exactly (disallows providing
  # abbreviated long option as short option).
  #
  # source://optparse//optparse.rb#1227
  def require_exact=(_arg0); end

  # Add separator in summary.
  #
  # source://optparse//optparse.rb#1606
  def separator(string); end

  # Heading banner preceding summary.
  # for experimental cascading :-)
  #
  # source://optparse//optparse.rb#1210
  def set_banner(_arg0); end

  # Program name to be emitted in error message and default banner,
  # defaults to $0.
  #
  # source://optparse//optparse.rb#1214
  def set_program_name(_arg0); end

  # Indentation for summary. Must be String (or have + String method).
  #
  # source://optparse//optparse.rb#1220
  def set_summary_indent(_arg0); end

  # Width for option list portion of summary. Must be Numeric.
  #
  # source://optparse//optparse.rb#1217
  def set_summary_width(_arg0); end

  # Puts option summary into +to+ and returns +to+. Yields each line if
  # a block is given.
  #
  # +to+:: Output destination, which must have method <<. Defaults to [].
  # +width+:: Width of left side, defaults to @summary_width.
  # +max+:: Maximum length allowed for left side, defaults to +width+ - 1.
  # +indent+:: Indentation, defaults to @summary_indent.
  #
  # source://optparse//optparse.rb#1337
  def summarize(to = T.unsafe(nil), width = T.unsafe(nil), max = T.unsafe(nil), indent = T.unsafe(nil), &blk); end

  # Indentation for summary. Must be String (or have + String method).
  #
  # source://optparse//optparse.rb#1220
  def summary_indent; end

  # Indentation for summary. Must be String (or have + String method).
  #
  # source://optparse//optparse.rb#1220
  def summary_indent=(_arg0); end

  # Width for option list portion of summary. Must be Numeric.
  #
  # source://optparse//optparse.rb#1217
  def summary_width; end

  # Width for option list portion of summary. Must be Numeric.
  #
  # source://optparse//optparse.rb#1217
  def summary_width=(_arg0); end

  # Terminates option parsing. Optional parameter +arg+ is a string pushed
  # back to be the first non-option argument.
  #
  # source://optparse//optparse.rb#1167
  def terminate(arg = T.unsafe(nil)); end

  # Returns option summary list.
  #
  # source://optparse//optparse.rb#1376
  def to_a; end

  # Returns option summary string.
  #
  # source://optparse//optparse.rb#1347
  def to_s; end

  # Subject of #on / #on_head, #accept / #reject
  #
  # source://optparse//optparse.rb#1298
  def top; end

  # Returns version string from program_name, version and release.
  #
  # source://optparse//optparse.rb#1279
  def ver; end

  # Version
  #
  # source://optparse//optparse.rb#1265
  def version; end

  # Version
  #
  # source://optparse//optparse.rb#1258
  def version=(_arg0); end

  # source://optparse//optparse.rb#1287
  def warn(mesg = T.unsafe(nil)); end

  private

  # Completes shortened long style option switch and returns pair of
  # canonical switch and switch descriptor OptionParser::Switch.
  #
  # +typ+::   Searching table.
  # +opt+::   Searching key.
  # +icase+:: Search case insensitive if true.
  # +pat+::   Optional pattern for completion.
  #
  # @raise [exc]
  #
  # source://optparse//optparse.rb#1849
  def complete(typ, opt, icase = T.unsafe(nil), *pat); end

  # Checks if an argument is given twice, in which case an ArgumentError is
  # raised. Called from OptionParser#switch only.
  #
  # +obj+:: New argument.
  # +prv+:: Previously specified argument.
  # +msg+:: Exception message.
  #
  # source://optparse//optparse.rb#1386
  def notwice(obj, prv, msg); end

  # source://optparse//optparse.rb#1633
  def parse_in_order(argv = T.unsafe(nil), setter = T.unsafe(nil), &nonopt); end

  # Searches +key+ in @stack for +id+ hash and returns or yields the result.
  #
  # source://optparse//optparse.rb#1832
  def search(id, key); end

  # Traverses @stack, sending each element method +id+ with +args+ and
  # +block+.
  #
  # source://optparse//optparse.rb#1821
  def visit(id, *args, &block); end

  class << self
    # See #accept.
    #
    # source://optparse//optparse.rb#1190
    def accept(*args, &blk); end

    # See #getopts.
    #
    # source://optparse//optparse.rb#1813
    def getopts(*args); end

    # Returns an incremented value of +default+ according to +arg+.
    #
    # source://optparse//optparse.rb#1124
    def inc(arg, default = T.unsafe(nil)); end

    # See #reject.
    #
    # source://optparse//optparse.rb#1203
    def reject(*args, &blk); end

    # source://optparse//optparse.rb#1170
    def terminate(arg = T.unsafe(nil)); end

    # source://optparse//optparse.rb#1175
    def top; end

    # Initializes a new instance and evaluates the optional block in context
    # of the instance. Arguments +args+ are passed to #new, see there for
    # description of parameters.
    #
    # This method is *deprecated*, its behavior corresponds to the older #new
    # method.
    #
    # source://optparse//optparse.rb#1115
    def with(*args, &block); end
  end
end

# Extends command line arguments array (ARGV) to parse itself.
module OptionParser::Arguable
  # source://optparse//optparse.rb#2303
  def initialize(*args); end

  # Substitution of getopts is possible as follows. Also see
  # OptionParser#getopts.
  #
  #   def getopts(*args)
  #     ($OPT = ARGV.getopts(*args)).each do |opt, val|
  #       eval "$OPT_#{opt.gsub(/[^A-Za-z0-9_]/, '_')} = val"
  #     end
  #   rescue OptionParser::ParseError
  #   end
  #
  # source://optparse//optparse.rb#2292
  def getopts(*args); end

  # Actual OptionParser object, automatically created if nonexistent.
  #
  # If called with a block, yields the OptionParser object and returns the
  # result of the block. If an OptionParser::ParseError exception occurs
  # in the block, it is rescued, a error message printed to STDERR and
  # +nil+ returned.
  #
  # source://optparse//optparse.rb#2251
  def options; end

  # Sets OptionParser object, when +opt+ is +false+ or +nil+, methods
  # OptionParser::Arguable#options and OptionParser::Arguable#options= are
  # undefined. Thus, there is no ways to access the OptionParser object
  # via the receiver object.
  #
  # source://optparse//optparse.rb#2234
  def options=(opt); end

  # Parses +self+ destructively in order and returns +self+ containing the
  # rest arguments left unparsed.
  #
  # source://optparse//optparse.rb#2267
  def order!(&blk); end

  # Parses +self+ destructively and returns +self+ containing the
  # rest arguments left unparsed.
  #
  # source://optparse//optparse.rb#2279
  def parse!; end

  # Parses +self+ destructively in permutation mode and returns +self+
  # containing the rest arguments left unparsed.
  #
  # source://optparse//optparse.rb#2273
  def permute!; end

  class << self
    # Initializes instance variable.
    #
    # source://optparse//optparse.rb#2299
    def extend_object(obj); end
  end
end

# Hash with completion search feature. See OptionParser::Completion.
class OptionParser::CompletingHash < ::Hash
  include ::OptionParser::Completion

  # Completion for hash key.
  #
  # source://optparse//optparse.rb#988
  def match(key); end
end

# Keyword completion module.  This allows partial arguments to be specified
# and resolved against a list of acceptable values.
module OptionParser::Completion
  # source://optparse//optparse.rb#462
  def candidate(key, icase = T.unsafe(nil), pat = T.unsafe(nil)); end

  # source://optparse//optparse.rb#467
  def complete(key, icase = T.unsafe(nil), pat = T.unsafe(nil)); end

  # source://optparse//optparse.rb#492
  def convert(opt = T.unsafe(nil), val = T.unsafe(nil), *_arg2); end

  class << self
    # source://optparse//optparse.rb#445
    def candidate(key, icase = T.unsafe(nil), pat = T.unsafe(nil), &block); end

    # source://optparse//optparse.rb#441
    def regexp(key, icase); end
  end
end

# Simple option list providing mapping from short and/or long option
# string to OptionParser::Switch and mapping from acceptable argument to
# matching pattern and converter pair. Also provides summary feature.
class OptionParser::List
  # Just initializes all instance variables.
  #
  # @return [List] a new instance of List
  #
  # source://optparse//optparse.rb#816
  def initialize; end

  # See OptionParser.accept.
  #
  # source://optparse//optparse.rb#837
  def accept(t, pat = T.unsafe(nil), &block); end

  # source://optparse//optparse.rb#961
  def add_banner(to); end

  # Appends +switch+ at the tail of the list, and associates short, long
  # and negated long options. Arguments are:
  #
  # +switch+::      OptionParser::Switch instance to be inserted.
  # +short_opts+::  List of short style options.
  # +long_opts+::   List of long style options.
  # +nolong_opts+:: List of long style options with "no-" prefix.
  #
  #   append(switch, short_opts, long_opts, nolong_opts)
  #
  # source://optparse//optparse.rb#901
  def append(*args); end

  # Map from acceptable argument types to pattern and converter pairs.
  #
  # source://optparse//optparse.rb#802
  def atype; end

  # Searches list +id+ for +opt+ and the optional patterns for completion
  # +pat+. If +icase+ is true, the search is case insensitive. The result
  # is returned or yielded if a block is given. If it isn't found, nil is
  # returned.
  #
  # source://optparse//optparse.rb#923
  def complete(id, opt, icase = T.unsafe(nil), *pat, &block); end

  # source://optparse//optparse.rb#970
  def compsys(*args, &block); end

  # Iterates over each option, passing the option to the +block+.
  #
  # source://optparse//optparse.rb#934
  def each_option(&block); end

  # @yield [__send__(id).keys]
  #
  # source://optparse//optparse.rb#927
  def get_candidates(id); end

  # List of all switches and summary string.
  #
  # source://optparse//optparse.rb#811
  def list; end

  # Map from long style option switches to actual switch objects.
  #
  # source://optparse//optparse.rb#808
  def long; end

  # Inserts +switch+ at the head of the list, and associates short, long
  # and negated long options. Arguments are:
  #
  # +switch+::      OptionParser::Switch instance to be inserted.
  # +short_opts+::  List of short style options.
  # +long_opts+::   List of long style options.
  # +nolong_opts+:: List of long style options with "no-" prefix.
  #
  #   prepend(switch, short_opts, long_opts, nolong_opts)
  #
  # source://optparse//optparse.rb#885
  def prepend(*args); end

  # source://optparse//optparse.rb#823
  def pretty_print(q); end

  # See OptionParser.reject.
  #
  # source://optparse//optparse.rb#853
  def reject(t); end

  # Searches +key+ in +id+ list. The result is returned or yielded if a
  # block is given. If it isn't found, nil is returned.
  #
  # source://optparse//optparse.rb#910
  def search(id, key); end

  # Map from short style option switches to actual switch objects.
  #
  # source://optparse//optparse.rb#805
  def short; end

  # Creates the summary table, passing each line to the +block+ (without
  # newline). The arguments +args+ are passed along to the summarize
  # method which is called on every option.
  #
  # source://optparse//optparse.rb#943
  def summarize(*args, &block); end

  private

  # Adds +sw+ according to +sopts+, +lopts+ and +nlopts+.
  #
  # +sw+::     OptionParser::Switch instance to be added.
  # +sopts+::  Short style option list.
  # +lopts+::  Long style option list.
  # +nlopts+:: Negated long style options list.
  #
  # source://optparse//optparse.rb#865
  def update(sw, sopts, lopts, nsw = T.unsafe(nil), nlopts = T.unsafe(nil)); end
end

# Map from option/keyword string to object with completion.
class OptionParser::OptionMap < ::Hash
  include ::OptionParser::Completion
end

# Base class of exceptions from OptionParser.
class OptionParser::ParseError < ::RuntimeError
  # @return [ParseError] a new instance of ParseError
  #
  # source://optparse//optparse.rb#2117
  def initialize(*args, additional: T.unsafe(nil)); end

  # Returns the value of attribute additional.
  #
  # source://optparse//optparse.rb#2126
  def additional; end

  # Sets the attribute additional
  #
  # @param value the value to set the attribute additional to.
  #
  # source://optparse//optparse.rb#2126
  def additional=(_arg0); end

  # Returns the value of attribute args.
  #
  # source://optparse//optparse.rb#2124
  def args; end

  # source://optparse//optparse.rb#2163
  def inspect; end

  # Default stringizing method to emit standard error message.
  #
  # source://optparse//optparse.rb#2170
  def message; end

  # Returns error reason. Override this for I18N.
  #
  # source://optparse//optparse.rb#2159
  def reason; end

  # Sets the attribute reason
  #
  # @param value the value to set the attribute reason to.
  #
  # source://optparse//optparse.rb#2125
  def reason=(_arg0); end

  # Pushes back erred argument(s) to +argv+.
  #
  # source://optparse//optparse.rb#2131
  def recover(argv); end

  # source://optparse//optparse.rb#2143
  def set_backtrace(array); end

  # source://optparse//optparse.rb#2147
  def set_option(opt, eq); end

  # Default stringizing method to emit standard error message.
  #
  # source://optparse//optparse.rb#2170
  def to_s; end

  class << self
    # source://optparse//optparse.rb#2136
    def filter_backtrace(array); end
  end
end

# Individual switch class.  Not important to the user.
#
# Defined within Switch are several Switch-derived classes: NoArgument,
# RequiredArgument, etc.
class OptionParser::Switch
  # @return [Switch] a new instance of Switch
  #
  # source://optparse//optparse.rb#543
  def initialize(pattern = T.unsafe(nil), conv = T.unsafe(nil), short = T.unsafe(nil), long = T.unsafe(nil), arg = T.unsafe(nil), desc = T.unsafe(nil), block = T.unsafe(nil), &_block); end

  # source://optparse//optparse.rb#640
  def add_banner(to); end

  # Returns the value of attribute arg.
  #
  # source://optparse//optparse.rb#513
  def arg; end

  # Returns the value of attribute block.
  #
  # source://optparse//optparse.rb#513
  def block; end

  # source://optparse//optparse.rb#659
  def compsys(sdone, ldone); end

  # Returns the value of attribute conv.
  #
  # source://optparse//optparse.rb#513
  def conv; end

  # Returns the value of attribute desc.
  #
  # source://optparse//optparse.rb#513
  def desc; end

  # Returns the value of attribute long.
  #
  # source://optparse//optparse.rb#513
  def long; end

  # @return [Boolean]
  #
  # source://optparse//optparse.rb#648
  def match_nonswitch?(str); end

  # Returns the value of attribute pattern.
  #
  # source://optparse//optparse.rb#513
  def pattern; end

  # source://optparse//optparse.rb#696
  def pretty_print(q); end

  # source://optparse//optparse.rb#677
  def pretty_print_contents(q); end

  # Returns the value of attribute short.
  #
  # source://optparse//optparse.rb#513
  def short; end

  # Produces the summary text. Each line of the summary is yielded to the
  # block (without newline).
  #
  # +sdone+::  Already summarized short style options keyed hash.
  # +ldone+::  Already summarized long style options keyed hash.
  # +width+::  Width of left side (option part). In other words, the right
  #            side (description part) starts after +width+ columns.
  # +max+::    Maximum width of left side -> the options are filled within
  #            +max+ columns.
  # +indent+:: Prefix string indents all summarized lines.
  #
  # source://optparse//optparse.rb#603
  def summarize(sdone = T.unsafe(nil), ldone = T.unsafe(nil), width = T.unsafe(nil), max = T.unsafe(nil), indent = T.unsafe(nil)); end

  # Main name of the switch.
  #
  # source://optparse//optparse.rb#655
  def switch_name; end

  private

  # Parses argument, converts and returns +arg+, +block+ and result of
  # conversion. Yields at semi-error condition instead of raising an
  # exception.
  #
  # source://optparse//optparse.rb#581
  def conv_arg(arg, val = T.unsafe(nil)); end

  # Parses +arg+ and returns rest of +arg+ and matched portion to the
  # argument pattern. Yields when the pattern doesn't match substring.
  #
  # @raise [InvalidArgument]
  # @yield [InvalidArgument, arg]
  #
  # source://optparse//optparse.rb#556
  def parse_arg(arg); end

  class << self
    # Guesses argument style from +arg+.  Returns corresponding
    # OptionParser::Switch class (OptionalArgument, etc.).
    #
    # source://optparse//optparse.rb#519
    def guess(arg); end

    # @raise [ArgumentError]
    #
    # source://optparse//optparse.rb#534
    def incompatible_argument_styles(arg, t); end

    # source://optparse//optparse.rb#539
    def pattern; end
  end
end

# Switch that takes no arguments.
class OptionParser::Switch::NoArgument < ::OptionParser::Switch
  # Raises an exception if any arguments given.
  #
  # @yield [NeedlessArgument, arg]
  #
  # source://optparse//optparse.rb#708
  def parse(arg, argv); end

  # source://optparse//optparse.rb#720
  def pretty_head; end

  class << self
    # source://optparse//optparse.rb#713
    def incompatible_argument_styles(*_arg0); end

    # source://optparse//optparse.rb#716
    def pattern; end
  end
end

# Switch that can omit argument.
class OptionParser::Switch::OptionalArgument < ::OptionParser::Switch
  # Parses argument if given, or uses default value.
  #
  # source://optparse//optparse.rb#754
  def parse(arg, argv, &error); end

  # source://optparse//optparse.rb#762
  def pretty_head; end
end

# Switch that takes an argument, which does not begin with '-' or is '-'.
class OptionParser::Switch::PlacedArgument < ::OptionParser::Switch
  # Returns nil if argument is not present or begins with '-' and is not '-'.
  #
  # source://optparse//optparse.rb#775
  def parse(arg, argv, &error); end

  # source://optparse//optparse.rb#789
  def pretty_head; end
end

# Switch that takes an argument.
class OptionParser::Switch::RequiredArgument < ::OptionParser::Switch
  # Raises an exception if argument is not present.
  #
  # source://optparse//optparse.rb#733
  def parse(arg, argv); end

  # source://optparse//optparse.rb#741
  def pretty_head; end
end

# source://optparse//optparse.rb#428
OptionParser::Version = T.let(T.unsafe(nil), String)
