
extends Node2D

var solutions = {}

var rule_count = 19
var number_count = 6

var rule_solutions = {}

func _ready():
	var rules = [0, 0, 0]
	for x in rule_count:
		for y in rule_count:
			for z in rule_count:
				if x == y or x == z or y == z:
					continue
				
				rules = [x, y, z]
				
				rules.sort()
				
				if rules in solutions.keys():
					continue
				
				solutions[rules] = []
				
				check_all_numbers(rules)
	
	print("number of rules: ")
	print(solutions.keys().size())
	print("\n~~~~~~~~~~")
	
	for solution in solutions.keys():
		if solutions[solution].size() == 0:
			print("No number code for: ")
			print(solution)
			print("~~~~~~~~~~")
	
	return
	for x in rule_count:
		rule_solutions[x] = 0
	
	for _rules in solutions.keys():
		for rule in _rules:
			for solution in solutions[_rules]:
				rule_solutions[rule] += 1
	
	for rule in rule_solutions:
		print(rule, ": ", rule_solutions[rule])

func check_all_numbers(rules : Array):
	for x in number_count:
		for y in number_count:
			for z in number_count:
				var numbers = [x, y, z]
				
				if !check_number(rules, numbers):
					continue
				
				solutions[rules].append(numbers)

func check_number(rules : Array, numbers : Array):
	for rule in rules:
		if !compare_rule(rule, numbers):
			return false
	
	return true

func compare_rule(rule: int, numbers : Array) -> bool:
	match rule:
		0: #0 and 2 odd
			if numbers[0] % 2 == 1 and numbers[2] % 2 == 1:
				return true
		1: #0 is 5
			if numbers[0] == 5:
				return true
		2: #1 is bigger than 2
			if numbers[1] > numbers[2]:
				return true
		3: #0 + 1 = 9
			if numbers[0] + numbers[1] == 9:
				return true
		4: #1 is 4
			if numbers[1] == 4:
				return true
		5: #0 and 1 are greater than 2
			if numbers[0] > 2 and numbers[1] > 2:
				return true
		6: #if 2 is 1
			if numbers[2] == 1:
				return true
		7: #0 + 1 + 2 > 9
			if numbers[0] + numbers[1] + numbers[2] > 9:
				return true
		8: #0 + 1 + 2 < 12 gaming
			if numbers[0] + numbers[1] + numbers[2] < 11:
				return true
		9: #1 is even
			if numbers[1] % 2 == 0:
				return true
		10: #0 = 1 + 2
			if numbers[0] == numbers[1] + numbers[2]:
				return true
		11: #1 is not 3 gaming
			if numbers[0] != 3 and numbers[1] != 3 and numbers[2] != 3:
				return true
		12: #1 + 2 is odd
			if (numbers[1] + numbers[2]) % 2 == 1:
				return true
		13: #0 > 1
			if numbers[0] > numbers[1]:
				return true
		14: #All greater than 0
			if numbers[0] > 0 and numbers[1] > 0 and numbers[2] > 0:
				return true
		15: #no duplicate numbers
			if numbers[0] != numbers[1] and numbers[0] != numbers[2] and numbers[2] != numbers[1]:
				return true
		16: #0 + 2 is 6
			if numbers[0] + numbers[2] == 6:
				return true
		17: #0 + 1 + 2 is even
			if (numbers[0] + numbers[1] + numbers[2]) % 2 == 0:
				return true
		18: #0 > 2
			if numbers[0] > numbers[2]:
				return true
	
	return false
