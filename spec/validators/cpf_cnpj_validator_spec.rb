require "rails_helper"

class Validatable
  include ActiveModel::Validations
  attr_accessor :document
  validates :document, cpf_cnpj: true
end

describe CpfCnpjValidator do
  subject { Validatable.new }

  context "when it is an invalid CPF" do
    before { subject.document = "431.321.551-12" }

    it "should be invalid" do
      expect(subject.valid?).to be_falsey
    end

    it "adds an error on model" do
      subject.valid?
      expect(subject.errors.keys).to include(:document)
    end
  end

  context "when it is an invalid CNPJ" do
    before { subject.document = "27.021.724/0001-53" }

    it "should be invalid" do
      expect(subject.valid?).to be_falsey
    end

    it "adds an error on model" do
      subject.valid?
      expect(subject.errors.keys).to include(:document)
    end
  end

  context "when it's does not have CPF or CNPJ format" do
    before { subject.document = "431.321" }

    it "should be invalid" do
      expect(subject.valid?).to be_falsey
    end

    it "adds an error on model" do
      subject.valid?
      expect(subject.errors.keys).to include(:document)
    end
  end

  it "is valid when it is a CPF" do
    subject.document = "865.922.358-61"
    expect(subject.valid?).to be_truthy
  end

  it "is valid when it is a CNPJ" do
    subject.document = "27.021.724/0001-78"
    expect(subject.valid?).to be_truthy
  end
end