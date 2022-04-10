require "option_parser"

# Crylox is a Lox interpreter in Crystal
module Crylox
  extend self
  VERSION = "0.1.0"

  cmd = OptionParser.parse do |parser|
    parser.banner = "Crylox is a Lox interpreter - #{VERSION}"

    parser.on "-f=FILE", "--file=FILE", "Interpret an Lox file" do |file|
      Executer.run_file(Path[file])
    end

    parser.on "-i", "--interactive", "An interactive Lox Session" do
      Executer.run_prompt
    end

    parser.invalid_option do |flag|
      STDERR.puts "Usage: crylox [script_file]"
      STDERR.puts parser
    end
  end

  class Executer
    property had_error

    def self.run_file(path : Path)
      self.run(File.read_lines(path))
    end

    def self.run(inputs : Array(String))
      puts "Not implemented"
      exit(65) if @@had_error
      exit
    end

    def self.run(command : String)
      # scanner : Scanner = Scanner.new(command)
      # tokens : Array(Tokens) = scanner.scanTokens
      # tokens.each do |i|
      #   puts i
      # end
      puts "Not implemented"
      @@had_error = false
    end

    def self.run_prompt
      puts "CryLox Interpreter - Press enter to exit"
      loop do
        print "CryLox> "
        command = gets(chomp: true)
        break if command.nil?
        break if command.empty?
        self.run command
      end
    end

    def self.error(line : Integer, message : String)
      self.report(line, "", message)
    end

    def self.report(line : Integer, where : Integer, message : String)
      puts <<-REPORT
      [line #{line}]: Error! #{where} - #{message}
      REPORT
    end
  end
end
