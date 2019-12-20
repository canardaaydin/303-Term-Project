OP_CODES = {
  'add'   => '000000',
  'sub'   => '000001',
  'mult'  => '000010',
  'and'   => '000011',
  'or'    => '000100',
  'addi'  => '000101',
  'sll'   => '000110',
  'slt'   => '000111',
  'mfhi'  => '001000',
  'mflo'  => '001001',
  'lw'    => '001010',
  'sw'    => '001011',
  'beq'   => '001100',
  'blez'  => '001101',
  'j'     => '001110',
  'jb'    => '001111'
}

filename = ARGV[0]
out_name = "#{filename.split('.')[0]}_out"

asm_file = File.open(filename)
out_file = File.new(out_name, 'w')

out_file.puts 'v2.0 raw'
puts "Created file: #{out_name}\n\n"

asm_file.readlines.map(&:chomp).each do |line|
  machine_string = ''

  imm_field = '00000000000' # default => shamt + func in R format
  regs_string = ''
  regs = []

  tokens = line.split(/[\s(), ]/)

  # handle comments
  comment_index = tokens.find_index '#'
  tokens = tokens[0...comment_index] unless comment_index.nil?
  next if tokens.length.zero? || tokens[0].include?('#') # line starts with comment

  instruction = tokens[0]
  format = instr_format instruction
  machine_string << OP_CODES[instruction]
  imm_field = '00000000000000000000000000' if instruction == 'jb'
  
  tokens[1..-1].each do |token|
    if token.length.positive?
      break if token.include?('#') # go to next line if token is comment
      case format
      when :J
        imm_field = fill_binary(decimal_to_binary(token), 26) if instruction == 'j'
      when :I
        if token[0] == '$'
          regs.append token[1..-1]
        else
          imm_field = fill_binary(decimal_to_binary(token), 16)
        end
      when :R
        if token[0] == '$'
          regs.append token[1..-1]
        else
          imm_field = fill_binary(decimal_to_binary(token), 5) << '000000'
        end
      end
    end
  end

  regs_string = get_i_regs_string(regs) if format == :I
  regs_string = get_r_regs_string(regs) if format == :R

  machine_string << regs_string << imm_field
  puts machine_string if instruction == 'jb'
  hex_string = binary_to_hex(machine_string)
  out_file.puts(hex_string + ' 0 0 0')
  puts hex_string
end

out_file.close

BEGIN {
  def fill_binary(bin_string, length)
      while bin_string.length < length
        bin_string = '0' + bin_string
      end
      return bin_string
  end

  def get_r_regs_string(regs)
    result = ''
    if regs.length == 1
      result << '0000000000' << reg_address(regs[0])
    elsif regs.length == 2
      result << reg_address(regs[1]) << reg_address(regs[0])
    elsif regs.length == 3
      result << reg_address(regs[1]) << reg_address(regs[2]) << reg_address(regs[0])
    end

    while result.length < 15
      result << '0'
    end

    return result
  end

  def get_i_regs_string(regs)
    result = ''
    regs.reverse.each do |reg|
      result << reg_address(reg)
    end
    while result.length < 10
      result << '0'
    end
    return result
  end

  def instr_format(instruction)
    if ['j', 'jb'].include? instruction
      return :J
    elsif ['sw', 'lw', 'addi', 'beq', 'blez'].include? instruction
      return :I
    else
      return :R
    end
  end

  def reg_address(reg)
    return fill_binary(reg.to_i.to_s(2), 5)
  end

  def binary_to_hex(binary)
    hex = binary.to_i(2).to_s(16)
    while hex.length < 8
      hex = '0' + hex
    end
    return hex
  end

  def decimal_to_binary(dec)
    return dec.to_i.to_s(2)
  end
}
