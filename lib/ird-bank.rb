require "yaml"

module IRD
  class Bank
    def self.all
        return load_banks
    end
    def self.bank(id)
        load_banks.each { |bank| return bank if bank["id"] == id }
        return false
    end
    def self.branches(id)
        load_banks.each { |bank| return bank["branches"] if bank["id"] == id }
        return false
    end
    def self.validate(bk, brch=0, acct=0, suf=0)
        if brch == 0 && acct == 0 && suf == 0
            bank = bk.split('-')[0].to_s.rjust(2, '0')
            branch = bk.split('-')[1].to_s.rjust(4, '0')
            account = bk.split('-')[2].to_s.rjust(8, '0')
            suffix = bk.split('-')[3].to_s.rjust(4, '0')
        else
            bank = bk.to_s.rjust(2, '0')
            branch = brch.to_s.rjust(4, '0')
            account = acct.to_s.rjust(8, '0')
            suffix = suf.to_s.rjust(4, '0')
        end
        bank_check = bank + branch + account + suffix
        return false if account == 0
        return false unless is_valid_branch? bank.to_i, branch.to_i
        return false unless bank_check.length == 18
        weight = weight_check(bank, account)

        counter = 0
        check = Array.new
        check_digit = weight.to_s.chars.each do |v| 
          check.push((v == 'A' ? 10 : v.to_i) * bank_check.split[counter].to_i) 
          counter += 1
        end
        counter = 0
        calc = check.inject(0, :+)
        check_num = modulo(bank)
        return calc % check_num === 0

    end
    def self.is_valid_bank?(id)
        return bank(id) ? true : false
    end
    def self.is_valid_branch?(bank, id)
        begin
            branches(bank).each do |branch| 
                return true if id.between?(branch["from"], branch["to"]) 
            end
            return false
        rescue NoMethodError => e
        return false
        end
    end

    private
    def self.modulo(bank)
        case bank
        when 29
            return 10
        when 31
            return 1
        else
            return 11
        end
    end
    def self.weight_check(bank, account)
        case bank
        when 8
            return '000000076543210000'
        when 9
            return '000000000054320001'
        when 29
            return '000000013713710371'
        when 31
            return '000000000000000000'
        else
            return '00637900A584210000' if account.to_i < 990000
            return '00000000A584210000' 
        end
    end
    def self.load_banks
        return YAML.load_file(File.join(File.dirname(__FILE__), "../config/banks.yml"))
    end
  end
end
