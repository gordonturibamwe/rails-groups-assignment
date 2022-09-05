require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "Send Messages" do
    let(:mail) { UserMailer.welcome_email }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to Zofi Cash.")
      expect(mail.to).to eq(["turibamwegordon@gmail.com"])
      expect(mail.from).to eq(["no-reply@zoficash.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Welcome to zoficash.com")
    end
  end
end
