$variables = Hash.new
$variable_type = Hash.new

$tab = "\011"

module Type
   UNKNOWN      = 0

   STRING       = 1
   INT          = 2
   FLOAT        = 3
   IDENT        = 4

   OPEN_PAREN   = 5
   CLOSED_PAREN = 6

   EQUALS       = 7

   PLUS         = 8
   TIMES        = 9
   DIVIDE       = 10
   MINUS        = 11

   COMMA        = 12

   PRINT        = 13
end

def only_ident_chars(string)
   result = false
   n = 0

   string.each_char do |char|
      if ('a'..'z').include? char
         n += 1
      elsif ('A'..'Z').include? char
         n += 1
      elsif char == "_"
         n += 1
      elsif (1..9).include? char.to_i
         n += 1
      elsif char == "0"
         n += 1
      else
         break
      end
   end

   if n == string.length
      result = true
   end
   
   return result, n
end

def is_ident_char(char)
   return true if char == "_"
   return true if ('a'..'z').include? char
   return true if ('A'..'Z').include? char

   return false
end

def only_digits(string)
   dot = false
   result = false

   n = 0

   string.each_char do |char|
      if (1..9).include? char.to_i
         n += 1
      elsif char == "0"  # Zero has to be checked seperatly from the above since char.to_i also returns 0 if it's not a digit.
         n += 1
      elsif char == "."
         if dot
            return false, n
         end

         if n == string.length-1
            return false, n
         end

         dot = true
         n += 1
      else
         break
      end
   end

   if n == string.length
      result = true
   end
   
   return result, n
end


def eat_spaces(string)
   n = 0

   # Remove the spaces at the front.
   string.each_char do |char|
      if char != " " and char != $tab
         break 
      end
      n += 1 
   end

   string = string[n..string.length-1]
   string = string.reverse

   # Remove the spaces at the end.
   n = 0
   string.each_char do |char|
      if char != " " and char != $tab
         break 
      end
      n += 1 
   end

   string = string[n..string.length-1]
   return string.reverse
end

def make_tokens(string)
   token = ""
   tokens = []

   space = false
   quote = false

   token_new = ["(", ")", "=", "+", "*", "/", "-", ","] 

   string.each_char do |char|
      # 
      # Double-Quote handling for strings.
      # 

      # Ending of a string.
      if char == "\"" and quote == true
         token += char 
         tokens.push(token)

         token = ""
         quote = false
         next
      end
      
      # Here, we are in a string.
      if quote == true
         token += char
         next
      end

      # This is the beginning of a new string.
      if char == "\""
         tokens.push(token) unless token == ""

         quote = true
         token = ""

         token += char
         next
      end

      #
      # Handling spaces between tokens.
      #

      if (char == " " or char == $tab) and space == true 
         next
      elsif char == " " or char == $tab
         space = true
         tokens.push(token) unless token == ""
         
         token = ""
      else
         if token_new.include? char  # For one-character tokens.
            tokens.push(token) unless token == ""
            tokens.push(char)
            token = ""
         else
            token += char
            space = false
         end
      end
   end

   # If quote is still true we haven't got another double quote but there has once been one.
   # Maybe later we want to use this to allow multi-line strings. Who knows?
   if quote == true
      puts "Error: Unexpected end of line while creating string token."
      return false
   end

   # This is important because we also have to create a new token even if there weren't any token-seperaters.
   tokens.push(token) unless token == ""

   if tokens.length == 0
      return false
   else
      return tokens
   end
end

def get_types(tokens)
   types = Hash.new(tokens.length)
   n = 0

   for token in tokens
      first = token[0]

      if first == "\""
         types[n] = Type::STRING


      elsif first == "("
         types[n] = Type::OPEN_PAREN
      elsif first == ")"
         types[n] = Type::CLOSED_PAREN

      elsif first == "="
         types[n] = Type::EQUALS

      elsif first == "+"
         types[n] = Type::PLUS
      elsif first == "-"
         types[n] = Type::MINUS
      elsif first == "*"
         types[n] = Type::TIMES
      elsif first == "/"
         types[n] = Type::DIVIDE

      elsif first == ","
         types[n] = Type::COMMA

      # 
      # Numbers.
      #

      elsif (1..9).include? first.to_i
         result, place = only_digits(token[1..token.length-1])

         if result == true
            if token.include? "."
               types[n] = Type::FLOAT
            else
               types[n] = Type::INT
            end
         else
            puts "Error: Invalid character '#{token[place+1]}' in integer token."
            return false
         end

      elsif is_ident_char(first)
         result, place = only_ident_chars(token[1..token.length-1])

         if result == true
            if token == "print"
               types[n] = Type::PRINT
            else
               types[n] = Type::IDENT
            end
         else
            puts "Error: Invalid character '#{token[place+1]}' in identifier token."
            return false
         end
      elsif first == "0"
         if token == "0"  # If the token is just '0' then we are ok.
            types[n] = Type::INT
         else # Otherwise:
            result, place = only_digits(token[1..token.length-1])

            if result == true
               if token.include? "."
                  types[n] = Type::FLOAT
               else
                  puts "Error: Invalid token '#{token}' since it's first character is '0'."
                  return false
               end
            else
               puts "Error: Invalid character '#{token[place+1]}' in integer token."
               return false
            end

         end
      else         
         types[n] = Type::UNKNOWN
      end

      n += 1
   end

   return types
end
