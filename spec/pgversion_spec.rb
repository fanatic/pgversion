require 'spec_helper'
require_relative '../lib/pgversion'

describe PGVersion do
  {
    "PostgreSQL 9.2.8 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2, 64-bit" =>
      PGVersion.new(9,2,8, host: 'x86_64-unknown-linux-gnu', compiler: 'gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2', bit_depth: 64),
    "PostgreSQL 9.1rc1 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2, 32-bit" =>
      PGVersion.new(9,1,:rc1, host: 'x86_64-unknown-linux-gnu', compiler: 'gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2', bit_depth: 32),
    "PostgreSQL 9.0beta2 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2, 64-bit" =>
      PGVersion.new(9,0,:beta2, host: 'x86_64-unknown-linux-gnu', compiler: 'gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2', bit_depth: 64),
    "PostgreSQL 8.4alpha3 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2, 64-bit" =>
      PGVersion.new(8,4,:alpha3, host: 'x86_64-unknown-linux-gnu', compiler: 'gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2', bit_depth: 64),
    "PostgreSQL 10.0.0 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2, 64-bit" =>
      PGVersion.new(10,0,0, host: 'x86_64-unknown-linux-gnu', compiler: 'gcc (Ubuntu 4.8.2-16ubuntu6) 4.8.2', bit_depth: 64)
  }.each do |version_str, version|
    describe '.parse' do
      it "parses #{version_str} into corresponding version #{version}" do
        expect(PGVersion.parse(version_str)).to eq(version)
      end
    end

    describe '#to_s' do
      it "formats #{version} into corresponding #{version_str}" do
        expect(version.to_s).to eq(version_str)
      end
    end
  end

  describe "#major_minor" do
    [ PGVersion.new(8,3,:alpha1),
      PGVersion.new(8,3,:alpha3),
      PGVersion.new(8,3,:beta1),
      PGVersion.new(8,3,:beta2),
      PGVersion.new(8,3,:rc1),
      PGVersion.new(8,3,:rc3),
      PGVersion.new(8,3,0),
      PGVersion.new(8,3,1),
      PGVersion.new(8,3) ].each do |version|
      it "should format #{version.to_s} as 8.3" do
        expect(version.major_minor).to eq("8.3")
      end
    end
  end

  describe "#<=>" do
    it "ignores bit_depth" do
      expect(PGVersion.new(9,0,0, bit_depth: 32) <=> PGVersion.new(9,0,0, bit_depth: 32)).to eq(0)
    end
    it "ignores host" do
      expect(PGVersion.new(9,0,0, host: "Linux") <=> PGVersion.new(9,0,0, host: "OS X")).to eq(0)
    end
    it "ignores compiler" do
      expect(PGVersion.new(9,0,0, compiler: "gcc") <=> PGVersion.new(9,0,0, compiler: "ICC")).to eq(0)
    end

    test_versions = [
      PGVersion.new(8,3,:alpha1),
      PGVersion.new(8,3,:alpha3),
      PGVersion.new(8,3,:beta1),
      PGVersion.new(8,3,:beta2),
      PGVersion.new(8,3,:rc1),
      PGVersion.new(8,3,:rc3),
      PGVersion.new(8,3,0),
      PGVersion.new(8,3,1),
      PGVersion.new(8,3),
      PGVersion.new(8,14,0),
      PGVersion.new(9,4,0),
      PGVersion.new(10,0,:alpha1),
      PGVersion.new(10,0,:alpha3),
      PGVersion.new(10,0,:beta1),
      PGVersion.new(10,0,:beta2),
      PGVersion.new(10,0,:rc1),
      PGVersion.new(10,0,:rc3),
      PGVersion.new(10,0,0),
      PGVersion.new(10,0,2),
      PGVersion.new(10,0,10),
      PGVersion.new(10,0)
    ].each_with_index.to_a.repeated_permutation(2).each do |(l,lidx), (r,ridx)|
      expected = lidx <=> ridx
      it "compares #{l} to #{r} and gets #{expected}" do
        expect(l <=> r).to eq(expected)
      end
      unless expected == 0
        opposite = expected * -1
        it "compares #{r} to #{l} and gets #{opposite}" do
          expect(r <=> l).to eq(opposite)
        end
      end
    end
  end
end
