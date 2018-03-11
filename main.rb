load "lexer.rb"
load "print.rb"
load "parser.rb"

while true
   print "=> "
   string = gets.chomp

   changed = true

   #
   #  ONLY FOR DEBUGGING PURPOSES.
   #   

   if string == "e"
      break
   end
   
   string = eat_spaces(string)

   line = make_tokens(string)
   next if line == false  # This means we've had an error or it was a blank line.

   types = get_types(line)
   next if types == false  # This means we've had an error.

   line = handle_comments(line, types)
   next if line == false or line.length == 0 
   
   types = get_types(line)
   next if types == false
   
   # High precedence artithmetic calculations.
   while true
      line, changed = do_arithmetic_high_precedence(line, types)
      break if !changed

      types = get_types(line)
   end

   next if !line
   changed = true

   # Low precedence artithmetic calculations.   
   while true
      line, changed = do_arithmetic_low_precedence(line, types)
      break if !changed

      types = get_types(line)
   end

   # puts
   # print line, "\n"
   # print types, "\n"
   # puts

   #next
   next if !line

   if types[0] == Type::IDENT
      if line[0] == "print"
         inst_print(line, types)

      else
         decl(line, types)

         # puts "Unknown identifier '#{line[0]}'."
      end

   else
      puts "Error: Right now, you can only start a line with an identifier!"
   end

end
