require 'spec_helper'

RSpec.describe ISO7064 do
  it "validate numeric check digit" do
    iso = ISO7064.new
    expect(iso.calculate_numeric_check_digit("036532", false)).to eq('0365323')
    expect(iso.calculate_numeric_check_digit("0794", false)).to eq('07945')
    expect(iso.calculate_numeric_check_digit("1000000000001", false)).to eq('10000000000011')
    expect(iso.calculate_numeric_check_digit("1000000000002", false)).to eq('10000000000020')
    expect(iso.calculate_numeric_check_digit("1000000000003", false)).to eq('10000000000038')
    expect(iso.calculate_numeric_check_digit("1000000000004", false)).to eq('10000000000046')
  end
end