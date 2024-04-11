struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount : Int
    var currency : String
    
    private let validCurrencies = ["USD", "GBP", "EUR", "CAN"]
    
    init(amount: Int, currency: String) {
        if validCurrencies.contains(currency) && amount >= 0 {
            self.currency = currency
            self.amount = amount
        } else {
            self.amount = 0
            self.currency = "BAD"
        }
    }
    
    func convert(_ currency: String) -> Money {
        switch currency{
        case "GBP":
            return Money(amount: Int(self.toUSD()/2.0), currency: currency)
        case "EUR":
            return Money(amount: Int(self.toUSD()/2.0*3.0), currency: currency)
        case "CAN":
            return Money(amount: Int(self.toUSD()/4.0*5.0), currency: currency)
        default:
            return Money(amount: Int(self.toUSD()), currency: currency)
        }
    }
    
    func add(_ money: Money) -> Money {
        let converted = self.convert(money.currency).amount
        return Money(amount: converted + money.amount, currency: money.currency)
    }
    
    func subtract(_ money: Money) -> Money {
        let converted = money.convert(self.currency)
        return Money(amount: converted.amount-amount, currency:currency)
    }
    
    private func toUSD() -> Double {
        switch currency {
        case "GBP":
            return Double(amount)*2.0
        case "EUR":
            return Double(amount)/3.0*2.0
        case "CAN":
            return Double(amount)/5.0*4.0
        default:
            return Double(amount)
        }
    }

}

////////////////////////////////////
// Job
//
public class Job {
    var title: String
    var type: JobType
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ year: Int) -> Int {
        switch type {
            case .Hourly(let wage):
                return Int(Double(wage) * Double(year))
            case .Salary(let salary):
                return Int(salary)
        }
    }
    
    func raise(byAmount: Int) {
        switch type {
            case .Hourly(let wage):
                type = .Hourly(wage + Double(byAmount))
            case .Salary(let salary):
                type = .Salary(salary + UInt(byAmount))
        }
    }
    
    func raise(byAmount: Double) {
        switch type {
            case .Hourly(let wage):
                type = .Hourly(wage + Double(byAmount))
            case .Salary(let salary):
                type = .Salary(salary + UInt(byAmount))
        }
    }
    
    func raise(byPercent: Double) {
        switch type {
            case .Hourly(let wage):
                type = .Hourly(wage * (1 + byPercent))
            case .Salary(let salary):
                let raisedSalary = Double(salary) * (1 + byPercent)
                type = .Salary(UInt(raisedSalary))
        }
    }
    
    func convert() {
        switch type {
            case .Hourly(let wage):
                let salaryEquivalent = wage * 2000.0
                let roundedSalary = Int(salaryEquivalent / 1000) * 1000
                type = .Salary(UInt(roundedSalary))
            case .Salary:
                print("Already a salaried position.")
        }
    }

}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String?
    var lastName: String?
    var age: Int
    var job: Job? {
        didSet {
            if age <= 18 {
                job = nil
            }
        }
    }
    var spouse: Person? {
        didSet {
            if age <= 21 {
                spouse = nil
            }
        }
    }
    
    init(firstName: String? = nil, lastName: String? = nil, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    func toString() -> String {
        var jobIncome = "nil"
        var spouseName = "nil"
        if job != nil {
             jobIncome = String(job!.calculateIncome(1))
        }
        if spouse != nil {
            spouseName = spouse!.firstName ?? "nil"
        }
        return "[Person: firstName:\(firstName ?? "nil") lastName:\(lastName ?? "nil") age:\(age) job:\(jobIncome) spouse:\(spouseName)]"
    }
    
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person] = []
    
    init(spouse1: Person, spouse2: Person) {
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        members = [spouse1, spouse2]
    }
    
    func haveChild(_ child: Person) -> Bool {
        if members.contains(where: { $0.age >= 21 }) {
            members.append(child)
            return true
        }
        return false
    }

    func householdIncome() -> Int {
        var sum = 0
        for member in members {
            if member.job != nil {
                let income = member.job!.calculateIncome(2000)
                sum += income
            }
        }
        return sum
    }
}
