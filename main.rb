require 'active_support'

$stack_arr = Array.new
$register_hash = {}

def print_stack
	puts "[stack]"
	puts $stack_arr
end

def print_register
	puts "[register]"
	puts $register_hash
end

def push_to_register(first_opr)
	if first_opr =~ /^[0-9]+$/ # 第一オペランドが数字ならtrue
		$stack_arr.push first_opr.to_i
	else
		$stack_arr.push $register_hash[first_opr]
	end
end

def pop_from_register(first_opr)
	$register_hash[first_opr] = $stack_arr.pop
end

def move_from_address(first_opr, second_opr)
	first_opr.slice!(0)
	first_opr.slice!(-1)
	if $stack_arr.size >= -$register_hash[first_opr] / 8
		$stack_arr[-$register_hash[first_opr] / 8] = $register_hash[second_opr]
	else
		$stack_arr.push $register_hash[second_opr]
	end
end

def move_to_address(first_opr, second_opr)
	second_opr.slice!(0)
	second_opr.slice!(-1)
	puts -$register_hash[second_opr] / 8
	$register_hash[first_opr] = $stack_arr[-$register_hash[second_opr] / 8]
end

def move_to_first_opr(first_opr, second_opr)
	if first_opr.start_with?("[")
		move_from_address(first_opr, second_opr)
		return
	elsif second_opr.start_with?("[")
		move_to_address(first_opr, second_opr)
		return
  # elsif second_opr =~ /^[0-9]+$/
	# 	$register_hash[first_opr] = second_opr
	else
		$register_hash[first_opr] = $register_hash[second_opr]
	end
end

def sub_second_opr(first_opr, second_opr)
	if second_opr =~ /^[0-9]+$/
		$register_hash[first_opr] -= second_opr.to_i
	else
		$register_hash[first_opr] -= $register_hash[second_opr]
	end
end

def add_second_opr(first_opr, second_opr)
	if second_opr =~ /^[0-9]+$/
		$register_hash[first_opr] += second_opr.to_i
	else
		$register_hash[first_opr] += $register_hash[second_opr]
	end
end

def imul_second_opr(first_opr, second_opr)
	if second_opr =~ /^[0-9]+$/
		$register_hash[first_opr] *= second_opr.to_i
	else
		$register_hash[first_opr] *= $register_hash[second_opr]
	end
end

def cqo
	$register_hash["rdx"] = 0
end

def idiv_second_opr(first_opr, second_opr)
	if second_opr.nil?
		tmp = $register_hash["rax"]
		$register_hash["rax"] = tmp / $register_hash[first_opr]
		$register_hash["rdx"] = tmp % $register_hash[first_opr]
		return;
	end

	if second_opr =~ /^[0-9]+$/
		$register_hash[first_opr] /= second_opr.to_i
	else
		$register_hash[first_opr] /= $register_hash[second_opr]
	end
end

def main
	opc_arr = ["push", "pop", "mov", "sub", "add", "imul", "cqo", "idiv"]
	# file = File.open("test.txt", "r")
	file = File.open(ARGV[0], "r")

	file.each_line{|line|
		puts line.lstrip
		line = line.gsub(",", "")
		line_li = line.split
	  if !opc_arr.include?(line_li[0])
			next
		end
		if line_li.size == 1
			first_opr = nil
		else
			first_opr = line_li[1]
			if !($register_hash.has_key?(first_opr) || first_opr =~ /^[0-9]+$/)
				$register_hash[first_opr] = 0
			end
		end
		if line_li.size <= 2
			second_opr = nil
		else
			second_opr = line_li[2]
			if !($register_hash.has_key?(second_opr) || second_opr =~ /^[0-9]+$/) 
				$register_hash[second_opr] = 0
			end
		end
		case line_li[0]
		when "push"
			push_to_register(first_opr)
		when "pop"	
			pop_from_register(first_opr)
		when "mov"
			move_to_first_opr(first_opr, second_opr)
		when "sub"
			sub_second_opr(first_opr, second_opr)
		when "add"
			add_second_opr(first_opr, second_opr)
		when "imul"
			imul_second_opr(first_opr, second_opr)
		when "cqo"
			cqo
		when "idiv"
			idiv_second_opr(first_opr, second_opr)
		end
		print_register
		print_stack
		puts 
	}


	file.close
	return "OK"
end

main