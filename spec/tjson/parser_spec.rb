# frozen_string_literal: true

RSpec.describe TJSON::Parser do
  describe ".parse" do
    context "UTF-8 strings" do
      let(:example_result) { "hello, world!" }
      let(:example_string) { "s:#{example_result}".dup }

      it "parses" do
        expect(described_class.parse(example_string)).to eq example_result
      end
    end

    context "untagged strings" do
      let(:example_string) { "hello, world!" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse(example_string) }.to raise_error(TJSON::ParseError)
      end
    end
  end

  describe ".parse_base16" do
    context "valid base16 string" do
      let(:example_base16) { "48656c6c6f2c20776f726c6421" }
      let(:example_result) { "Hello, world!" }

      it "parses successfully" do
        result = described_class.parse_base16(example_base16)
        expect(result).to eq example_result
        expect(result.encoding).to eq Encoding::BINARY
      end
    end

    context "invalid base16 string" do
      let(:invalid_base16) { "Surely this is not valid base16!" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_base16(invalid_base16) }.to raise_error(TJSON::ParseError)
      end
    end
  end

  describe ".parse_base32" do
    context "valid base32 string" do
      let(:example_base32) { "jbswy3dpfqqho33snrscc" }
      let(:example_result) { "Hello, world!" }

      it "parses successfully" do
        result = described_class.parse_base32(example_base32)
        expect(result).to eq example_result
        expect(result.encoding).to eq Encoding::BINARY
      end
    end

    context "padded base32 string" do
      let(:padded_base32) { "jbswy3dpfqqho33snrscc===" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_base32(padded_base32) }.to raise_error(TJSON::ParseError)
      end
    end

    context "invalid base32 string" do
      let(:invalid_base32) { "Surely this is not valid base32!" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_base32(invalid_base32) }.to raise_error(TJSON::ParseError)
      end
    end
  end

  describe ".parse_base64url" do
    context "valid base64url string" do
      let(:example_base64url) { "SGVsbG8sIHdvcmxkIQ" }
      let(:example_result)    { "Hello, world!" }

      it "parses successfully" do
        result = described_class.parse_base64url(example_base64url)
        expect(result).to eq example_result
        expect(result.encoding).to eq Encoding::BINARY
      end
    end

    context "padded base64url string" do
      let(:padded_base64url) { "SGVsbG8sIHdvcmxkIQ==" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_base16(padded_base64url) }.to raise_error(TJSON::ParseError)
      end
    end

    context "invalid base64url string" do
      let(:invalid_base64url) { "Surely this is not valid base64url!" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_base16(invalid_base64url) }.to raise_error(TJSON::ParseError)
      end
    end
  end

  context "integers" do
    describe ".parse_signed_int" do
      context "valid integer string" do
        let(:example_string)  { "42" }
        let(:example_integer) { 42 }

        it "parses successfully" do
          expect(described_class.parse_signed_int(example_string)).to eq example_integer
        end
      end

      context "MAXINT for 64-bit signed integer" do
        let(:example_string)  { "9223372036854775807" }
        let(:example_integer) { (2**63) - 1 }

        it "parses successfully" do
          expect(described_class.parse_signed_int(example_string)).to eq example_integer
        end
      end

      context "-MAXINT for 64-bit signed integer" do
        let(:example_string)  { "-9223372036854775808" }
        let(:example_integer) { -(2**63) }

        it "parses successfully" do
          expect(described_class.parse_signed_int(example_string)).to eq example_integer
        end
      end

      context "oversized signed integer string" do
        let(:oversized_example) { "9223372036854775808" }

        it "raises TJSON::ParseError" do
          expect { described_class.parse_signed_int(oversized_example) }.to raise_error(TJSON::ParseError)
        end
      end

      context "undersized signed integer string" do
        let(:oversized_example) { "-9223372036854775809" }

        it "raises TJSON::ParseError" do
          expect { described_class.parse_signed_int(oversized_example) }.to raise_error(TJSON::ParseError)
        end
      end
    end

    describe ".parse_unsigned_int" do
      context "valid integer string" do
        let(:example_string)  { "42" }
        let(:example_integer) { 42 }

        it "parses successfully" do
          expect(described_class.parse_unsigned_int(example_string)).to eq example_integer
        end
      end

      context "MAXINT for 64-bit unsigned integer" do
        let(:example_string)  { "18446744073709551615" }
        let(:example_integer) { (2**64) - 1 }

        it "parses successfully" do
          expect(described_class.parse_unsigned_int(example_string)).to eq example_integer
        end
      end

      context "oversized unsigned integer string" do
        let(:oversized_example) { "18446744073709551616" }

        it "raises TJSON::ParseError" do
          expect { described_class.parse_unsigned_int(oversized_example) }.to raise_error(TJSON::ParseError)
        end
      end

      context "negative unsigned integer" do
        let(:example_string) { "-1" }

        it "raises TJSON::ParseError" do
          expect { described_class.parse_unsigned_int(example_string) }.to raise_error(TJSON::ParseError)
        end
      end
    end
  end

  describe ".parse_timestamp" do
    context "valid UTC RFC3339 timestamp" do
      let(:example_timestamp) { "2016-10-02T07:31:51Z" }

      it "parses successfully" do
        expect(described_class.parse_timestamp(example_timestamp)).to be_a Time
      end
    end

    context "RFC3339 timestamp with non-UTC time zone" do
      let(:invalid_timestamp) { "2016-10-02T07:31:51-08:00" }

      it "raises TJSON::ParseError" do
        expect { described_class.parse_timestamp(invalid_timestamp) }.to raise_error(TJSON::ParseError)
      end
    end
  end
end
