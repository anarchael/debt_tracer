require "json"

class Debt
	attr_accessor :recipient, :amount

	def initialize(recipient = "undefined", amount = 0)
		@recipient = recipient
		@amount = amount
	end

	def to_s
		return "Debt to #{@recipient} : #{amount}€"
	end
end

def add_debt(debt)
	registered_debts = JSON.load(File.open("debts.json", "r")) if File.exist? ("debts.json")
	file = File.open("debts.json", "w")
	if not registered_debts.nil?
		(registered_debts["debts"][debt.recipient].nil?) ? registered_debts["debts"][debt.recipient] = debt.amount : registered_debts["debts"][debt.recipient] += debt.amount
	else
		registered_debts = {"debts" => {debt.recipient => debt.amount}}
	end
	file.write(registered_debts.to_json)
end

def del_debt(recipient)
	return if not File.exist?("debts.json")
	file = File.open("debts.json", "r")
	registered_debts = JSON.load(file).to_hash
	(ARGV[2].nil? or ARGV[2].to_f >= registered_debts["debts"][recipient]) ? registered_debts["debts"][recipient] = nil : registered_debts["debts"][recipient] -= ARGV[2].to_f
	registered_debts["debts"].compact!
	file = File.open("debts.json", "w")
	file.write(registered_debts.to_json)
	file.close
end

def get_debt
	return if not File.exist?("debts.json")
	file = File.open("debts.json", "r")
	json = JSON.load(file)
	debt = json["debts"][ARGV[1].to_s]
	puts Debt.new(ARGV[1].to_s, debt)
end

def debt_list
	return if not File.exist?("debts.json")
	file = File.open("debts.json", "r")
	json = JSON.load(file)
	debts = json["debts"].to_hash
	total_debt = 0
	json["debts"].each_entry {|key, value| puts Debt.new(key, value);total_debt+=value} if debts.size > 0
	puts "Total : #{total_debt}€"
end

if __FILE__ == $0
	case ARGV[0].downcase
	when "add" 
		add_debt(Debt.new(ARGV[1].to_s, ARGV[2].to_f))
	when "del"
		del_debt(ARGV[1].to_s)
	when "list"
		debt_list
	when "get"
		get_debt
	end
end