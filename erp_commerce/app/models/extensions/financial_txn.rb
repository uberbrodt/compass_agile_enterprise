FinancialTxn.class_eval do
  has_many :payments
  has_many :payment_applications, :dependent => :destroy
end