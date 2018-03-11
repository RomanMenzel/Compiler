# coding: utf-8

def handle_comments(line, types)
   n = 0
   found = false

   for token in line
      t = types[n]

      if t == Type::DIVIDE
         if found == true
            if n == 1
               line = line.clear
               break
            end

            line = line[0..n-2]  # Here it is n-2 because we use '..' instead of '...'.
            break
         end

         found = true
      end

      n += 1         
   end

   return line
end

                     

def do_arithmetic_low_precedence(line, types)
   n = 0
   changed = false  # If this is true, there was something changed so we have to know that.

   for token in line
      if types[n] == Type::PLUS
         if n == 0   # If n == 0 then the index of 'left' will be -1 so the last element (rubys syntax). This is not right.
            puts "Error: Missing left side of arithmetic calculation."
            return false, false
         end

         left  = line[n-1]
         right = line[n+1]

         left_type  = types[n-1]
         right_type = types[n+1]

         error = false
         float = false

         if right == nil
            puts "Error: Missing right side of arithmetic calculation."
            return false, false
         end
         
         # This looks for identfiers on the left.
         if left_type == Type::IDENT
            if $variables.keys.include? left
               if $variable_type[left] != Type::INT
                  if $variable_type[left] != Type::FLOAT
                     puts "Error: Identifier '#{left}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     left_type = $variable_type[left] 
                     left = $variables[left]
                  end
               else
                  left_type = $variable_type[left] 
                  left = $variables[left]
               end
            else
               puts "Error: Undeclared identifier '#{left}' in arithmetic calulation."
               return false, false
            end
         end

         # This looks for identfiers on the right.
         if right_type == Type::IDENT
            if $variables.keys.include? right
               if $variable_type[right] != Type::INT
                  if $variable_type[right] != Type::FLOAT
                     puts "Error: Identifier '#{right}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     right_type = $variable_type[right] 
                     right = $variables[right]
                  end
               else
                  right_type = $variable_type[right] 
                  right = $variables[right]
               end
            else
               puts "Error: Undeclared identifier '#{right}' in arithmetic calulation."
               return false, false
            end
         end


         if left_type != Type::INT
            if left_type != Type::FLOAT
               puts "Error: Left side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if right_type != Type::INT
            if right_type != Type::FLOAT
               puts "Error: Right side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if error
            return false, false
         end

         if float 
            result = (left.to_f + right.to_f).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         else
            result = (left.to_i + right.to_i).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         end
      elsif types[n] == Type::MINUS
         if n == 0   # If n == 0 then the index of 'left' will be -1 so the last element (rubys syntax). This is not right.
            puts "Error: Missing left side of arithmetic calculation."
            return false, false
         end

         left  = line[n-1]
         right = line[n+1]

         left_type  = types[n-1]
         right_type = types[n+1]

         error = false
         float = false

         if right == nil
            puts "Error: Missing right side of arithmetic calculation."
            return false, false
         end
         
         # This looks for identfiers on the left.
         if left_type == Type::IDENT
            if $variables.keys.include? left
               if $variable_type[left] != Type::INT
                  if $variable_type[left] != Type::FLOAT
                     puts "Error: Identifier '#{left}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     left_type = $variable_type[left] 
                     left = $variables[left]
                  end
               else
                  left_type = $variable_type[left] 
                  left = $variables[left]
               end
            else
               puts "Error: Undeclared identifier '#{left}' in arithmetic calulation."
               return false, false
            end
         end

         # This looks for identfiers on the right.
         if right_type == Type::IDENT
            if $variables.keys.include? right
               if $variable_type[right] != Type::INT
                  if $variable_type[right] != Type::FLOAT
                     puts "Error: Identifier '#{right}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     right_type = $variable_type[right] 
                     right = $variables[right]
                  end
               else
                  right_type = $variable_type[right] 
                  right = $variables[right]
               end
            else
               puts "Error: Undeclared identifier '#{right}' in arithmetic calulation."
               return false, false
            end
         end


         if left_type != Type::INT
            if left_type != Type::FLOAT
               puts "Error: Left side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if right_type != Type::INT
            if right_type != Type::FLOAT
               puts "Error: Right side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if error
            return false, false
         end

         if float 
            result = (left.to_f - right.to_f).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         else
            result = (left.to_i - right.to_i).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         end
      end

      n += 1
   end

   return line, changed
end

def do_arithmetic_high_precedence(line, types)
   n = 0
   changed = false
   
   for token in line
      if types[n] == Type::TIMES
         if n == 0 
            puts "Error: Missing left side of arithmetic calculation."
            return false, false
         end

         left  = line[n-1]
         right = line[n+1]

         left_type  = types[n-1]
         right_type = types[n+1]

         error = false
         float = false

         if right == nil
            puts "Error: Missing right side of arithmetic calculation."
            return false, false
         end

         # This looks for identfiers on the left.
         if left_type == Type::IDENT
            if $variables.keys.include? left
               if $variable_type[left] != Type::INT
                  if $variable_type[left] != Type::FLOAT
                     puts "Error: Identifier '#{left}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     left_type = $variable_type[left] 
                     left = $variables[left]
                  end
               else
                  left_type = $variable_type[left] 
                  left = $variables[left]
               end
            else
               puts "Error: Undeclared identifier '#{left}' in arithmetic calulation."
               return false, false
            end
         end

         # This looks for identfiers on the right.
         if right_type == Type::IDENT
            if $variables.keys.include? right
               if $variable_type[right] != Type::INT
                  if $variable_type[right] != Type::FLOAT
                     puts "Error: Identifier '#{right}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     right_type = $variable_type[right] 
                     right = $variables[right]
                  end
               else
                  right_type = $variable_type[right] 
                  right = $variables[right]
               end
            else
               puts "Error: Undeclared identifier '#{right}' in arithmetic calulation."
               return false, false
            end
         end

         if left_type != Type::INT
            if left_type != Type::FLOAT
               puts "Error: Left side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if right_type != Type::INT
            if right_type != Type::FLOAT
               puts "Error: Right side of arithmetic calculation is neither an integer nor a float."
               error = true
            else
               float = true
            end
         end

         if error
            return false, false
         end

         if float 
            result = (left.to_f * right.to_f).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         else
            result = (left.to_i * right.to_i).to_s
            line[n-1..n+1] = result  # Replace the 3 entries with the result.

            changed = true
            return line, changed
         end
      elsif types[n] == Type::DIVIDE
         if n == 0 
            puts "Error: Missing left side of arithmetic calculation."
            return false, false
         end

         left  = line[n-1]
         right = line[n+1]

         left_type  = types[n-1]
         right_type = types[n+1]

         if right == nil
            puts "Error: Missing right side of arithmetic calculation."
            return false, false
         elsif right == "0"
            puts "Error: Dividing by zero!"
            return false, false
         end

         # This looks for identfiers on the left.
         if left_type == Type::IDENT
            if $variables.keys.include? left
               if $variable_type[left] != Type::INT
                  if $variable_type[left] != Type::FLOAT
                     puts "Error: Identifier '#{left}' is not of numeric type."
                     return false, false
                  else 
                     # Replace the identifier with the actual value of it and set the type to the type of the identfiers value.
                     left_type = $variable_type[left] 
                     left = $variables[left]
                  end
               else
                  left_type = $variable_type[left] 
                  left = $variables[left]
               end
            else
               puts "Error: Undeclared identifier '#{left}' in arithmetic calulation."
               return false, false
            end
         end

         # This looks for identfiers on the right.
         if right_type == Type::IDENT
            if $variables.keys.include? right
               if $variable_type[right] != Type::INT
                  if $variable_type[right] != Type::FLOAT
                     puts "Error: Identifier '#{right}' is not of numeric type."
                     return false, false
                  else 
                     temp_right = right

                     right_type = $variable_type[right] 
                     right = $variables[right]
                  end
               else
                  temp_right = right

                  right_type = $variable_type[right] 
                  right = $variables[right]
               end
            else
               puts "Error: Undeclared identifier '#{right}' in arithmetic calulation."
               return false, false
            end
         end

         # Here, we want to use 0 as an integer (not a string) because in $variables ints don't get stored as a string,
         # they get stored with the actual int-value.
         if right == 0
            puts "Error: Dividing by zero ('#{temp_right}' = 0)."
            return false, false
         end

         if left_type != Type::INT
            if left_type != Type::FLOAT
               puts "Error: Left side of arithmetic calculation is neither an integer nor a float."
               return false, false
            end
         end

         if right_type != Type::INT
            if right_type != Type::FLOAT
               puts "Error: Right side of arithmetic calculation is neither an integer nor a float."
               return false, false
            end
         end

         # For divide-operations we always want to convert to float because it usually returns a float.
         result = (left.to_f / right.to_f).to_s  
         line[n-1..n+1] = result  # Replace the 3 entries with the result.

         changed = true
         return line, changed
      end

      n += 1
   end

   return line, changed
end

def decl(line, types)
   ident = line[0]

   if types[1] == Type::EQUALS
      # print line, "\n"
      # print types, "\n"

      # String declaration.
      if types[2] == Type::STRING
         if $variables.keys.include? ident
            puts "Error: Attempt to redeclare identifier '#{ident}'."
         else
            if line[3] == nil
               string_value = line[2][1..line[2].length-2]

               $variables[ident] = string_value
               $variable_type[ident] = Type::STRING
            else
               puts "Error: Unexpected token '#{line[3]}'."
            end
         end

      # Integer declaration.
      elsif types[2] == Type::INT
         if $variables.keys.include? ident
            puts "Error: Attempt to redeclare identifier '#{ident}'."
         else
            if line[3] == nil
               int_value = line[2].to_i

               $variables[ident] = int_value
               $variable_type[ident] = Type::INT
            else
               puts "Error: Unexpected token '#{line[3]}'."
            end
         end
      # Float declaration.
      elsif types[2] == Type::FLOAT
         if $variables.keys.include? ident
            puts "Error: Attempt to redeclare identifier '#{ident}'."
         else
            if line[3] == nil
               float_value = line[2].to_f

               $variables[ident] = float_value
               $variable_type[ident] = Type::FLOAT
            else
               puts "Error: Unexpected token '#{line[3]}'."
            end
         end
      # Declarations based on other identifiers.
      elsif types[2] == Type::IDENT
         if $variables.keys.include? ident
            puts "Error: Attempt to redeclare identifier '#{ident}'."
         else
            if line[3] == nil
               if $variables.keys.include? line[2]
                  $variables[ident] = $variables[line[2]]
                  $variable_type[ident] = $variable_type[line[2]]

                  # print $variables, "\n"
                  # print $variable_type, "\n"
               else
                  puts "Error: Undeclared identifier '#{line[2]}'."
               end
            else
               puts "Error: Unexpected token '#{line[3]}'."
            end
         end
      else
         if line[2] == nil
            puts "Error: Expected token after '='."
         else
            puts "Error: For now, you can only assign a string or a numeric value to a variable."
         end
      end
   else
      puts "Error: Expected '=' after identifier '#{line[0]}'."
   end
end



