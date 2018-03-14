# coding: utf-8

def insert_args(args, args_types, string)
   for i, t in args_types
      if t == Type::IDENT
         ident = args[i]

         if !($variables.keys.include? ident)
            puts "Error: Undeclared identifier '#{ident}' in arguments of print function."
            return false
         else
            args[i] = $variables[ident].to_s # We want the value to be converted to string so the handling down below will be easier.
         end
      elsif t == Type::STRING
         args[i] = args[i][1..args[i].length-2]  # We don't want strange internal quotes so let's just get rid of them.
      end
   end

   n = 0
   w = 0

   string.each_char do |char|
      if char == "%"
         arg_value = args[w]

         string[n] = ""  # Delete the placeholder.
         string = string.insert(n, arg_value)  # Insert removes the quotes since it is a string internally.

         w += 1
         n += arg_value.length-1
      end

      n += 1
   end

   return string
end

def is_correct_order(line, types)
   comma = false
   args = Array.new

   allowed = [Type::FLOAT, Type::INT, Type::STRING, Type::IDENT]

   for n, t in types
      if allowed.include? t
         if comma == true
            args.push(line[n])
            comma = false
         else
            puts "Error: Argument '#{line[n]}' without comma."
            return false, nil
         end
      elsif t == Type::COMMA
         if comma == true
            puts "Error: Two consecutive commas."
            return false, nil
         else
            comma = true
         end
      else
         unless (n == types.keys.length-1 and t == Type::CLOSED_PAREN)
            puts "Error: Invalid token '#{line[n]}' in arguments of print function."
            return false, nil
         end
      end
   end

   # If comma is still true, we got a comma without an argument.
   if comma == true
      puts "Error: Comma without argument."
      return false, nil
   elsif types[line.length-1] != Type::CLOSED_PAREN
      puts "Error: Missing ')' at end of line."
      return false, nil
   end

   return true, args
end
  

def inst_print(line, types)
   # For some reason, we have to set the default value for the hash because otherwise ruby will
   # give 'arg' strange random values if it doesn't exist. So if it doesn't exist, nil will be assigned
   # to it so the 'else' statment will take care of it.
   types.default = nil 
   arg = types[2]

   if types[1] == Type::OPEN_PAREN
      # print string.
      if arg == Type::STRING
         
         if types[3] == Type::CLOSED_PAREN

            # Do we have any remaining tokens after the ')'? 
            if line[4] != nil
               puts "Error: Unexpected token '#{line[4]}'."
               return false
            end

            string_value = line[2][1..line[2].length-2]
            
            puts string_value # We want to print a newline by default so we use puts here.
         else  # Look for arguments.
            n = 0
            
            remaining = line[3..line.length-1]
            remaining_types = Hash.new

            for w in 3..line.length-1
               remaining_types[n] = types[w]

               n += 1
            end

            # Check for valid order in the argument list.
            result, args = is_correct_order(remaining, remaining_types)

            if result == true
               allowed = [Type::STRING, Type::INT, Type::FLOAT, Type::IDENT]

               n = 0
               args_types = Hash.new
               
               # This loop gets the types of arguments (and we can do that because we know that the order correct).
               remaining_types.values.each do |t|
                  if allowed.include? t
                     args_types[n] = t
                     n += 1
                  end
               end

               string = line[2]
               percents = string.count("%") 

               if percents != args.length
                  puts "Error: Wrong number of arguments in print function (expected #{percents}, got #{args.length})."
               else
                  line = insert_args(args, args_types, string)
                  if line != false
                     puts line[1..line.length-2]  # Internally the arguments are stored as strings so we have to remove the quotes.
                  end
               end
            end

         end

      # print ident.
      elsif arg == Type::IDENT
         ident = line[2]
         if $variables.keys.include? ident

            if types[3] == Type::CLOSED_PAREN
               # Do we have any remaining tokens after the ')'? 
               if line[4] != nil
                  puts "Error: Unexpected token '#{line[4]}'."
                  return false
               end

               puts $variables[ident]

            else
               puts "Error: Expected ')' after identifier '#{ident}'."
            end
         else
            puts "Error: Unknown identifier '#{ident}'."
         end

      # print int.
      elsif arg == Type::INT
            if line[4] != nil
               puts "Error: Unexpected token '#{line[4]}'."
               return false
            end

            int_value = line[2]
            puts int_value
      # print float.
      elsif arg == Type::FLOAT
            if line[4] != nil
               puts "Error: Unexpected token '#{line[4]}'."
               return false
            end

            float_value = line[2]
            puts float_value
      else
         puts "Error: Expected a string in 'print' instruction."
      end
      
   else
      puts "Error: Expected '(' after 'print' instruction."
   end
end
