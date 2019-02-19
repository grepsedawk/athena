class Customer
  include CrSerializer

  property name : String = "MyCust"
  property id : Int32 = 1
end

class User
  include CrSerializer

  property id : Int64?

  @[Assert::GreaterThan(value: 0)]
  property age : Int32

  @[CrSerializer::Options(groups: ["admin"])]
  property password : String = "monkey"

  @[CrSerializer::Expandable]
  property customer : Customer?

  def customer : Customer
    Customer.new
  end

  # Mock out find method to emulate ORM method
  def self.find(val) : User?
    user : self = new
    if val.to_i == 17
      user.id = 17
      user.age = 123
      user
    elsif val == "71"
      user.id = 71
      user.age = 321
      user
    else
      nil
    end
  end

  def self.from_form_data(form_data : HTTP::Params) : self
    obj = new
    obj.age = form_data["age"].to_i
    obj.id = form_data["id"].to_i64
    obj
  end

  ECR.def_to_s "spec/routing/user.ecr"
end

class UserController < Athena::Routing::ClassController
  @[Athena::Routing::Post(path: "users")]
  @[Athena::Routing::ParamConverter(param: "body", type: User, converter: RequestBody)]
  def self.new_user(body : User) : User
    body.id = 12
    body
  end

  @[Athena::Routing::Post(path: "users/form")]
  @[Athena::Routing::ParamConverter(param: "body", type: User, converter: FormData)]
  def self.new_form_user(body : User) : User
    body.should be_a User
    body.id.should eq 99
    body.age.should eq 1
    body.password.should eq "monkey"
    body
  end

  @[Athena::Routing::Put(path: "users")]
  @[Athena::Routing::ParamConverter(param: "body", type: User, converter: RequestBody)]
  def self.update_user(body : User) : User
    body.should be_a User
    body.id.should eq 17_i64
    body.age.should eq 99
    body.password.should eq "monkey"
    body
  end

  @[Athena::Routing::Get(path: "users/yaml/:user_id")]
  @[Athena::Routing::ParamConverter(param: "user", param_type: Int64, type: User, converter: Exists)]
  @[Athena::Routing::View(renderer: YAMLRenderer)]
  def self.get_user_yaml(user : User) : User
    user
  end

  @[Athena::Routing::Get(path: "users/ecr/:user_id")]
  @[Athena::Routing::ParamConverter(param: "user", param_type: Int64, type: User, converter: Exists)]
  @[Athena::Routing::View(renderer: ECRRenderer)]
  def self.get_user_ecr(user : User) : User
    user
  end

  @[Athena::Routing::Get(path: "users/:user_id")]
  @[Athena::Routing::ParamConverter(param: "user", param_type: Int64, type: User, converter: Exists)]
  def self.get_user(user : User) : User
    user.should be_a User
    user.id.should eq 17
    user.age.should eq 123
    user.password.should eq "monkey"
    user
  end

  @[Athena::Routing::Get(path: "users/str/:user_id")]
  @[Athena::Routing::ParamConverter(param: "user", param_type: String, type: User, converter: Exists)]
  def self.get_user_string(user : User) : User
    user.should be_a User
    user.id.should eq 71
    user.age.should eq 321
    user.password.should eq "monkey"
    user
  end

  @[Athena::Routing::Get(path: "admin/users/:user_id")]
  @[Athena::Routing::View(groups: ["admin"])]
  @[Athena::Routing::ParamConverter(param: "user", param_type: Int64, type: User, converter: Exists)]
  def self.get_user_admin(user : User) : User
    user.should be_a User
    user.id.should eq 17
    user.age.should eq 123
    user.password.should eq "monkey"
    user
  end

  @[Athena::Routing::Get(path: "admin/users/:user_id/all")]
  @[Athena::Routing::View(groups: ["admin", "default"])]
  @[Athena::Routing::ParamConverter(param: "user", param_type: Int64, type: User, converter: Exists)]
  def self.get_user_admin_all(user : User) : User
    user.should be_a User
    user.id.should eq 17
    user.age.should eq 123
    user.password.should eq "monkey"
    user
  end
end