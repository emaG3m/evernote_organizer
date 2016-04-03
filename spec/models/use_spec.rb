require 'spec_helper'

describe User do
  describe '.authenticate' do
    let!(:user) { User.create!(email: 'example@test.com', password: '12345') }

    context 'with a matching password' do
      it 'returns the instance of the user' do
        expect(User.authenticate('example@test.com', '12345')).to eq(user)
      end
    end

    context 'with a user that does not exist' do
      it 'returns nil' do
        expect(User.authenticate('random@email.com', '12345')).to eq(nil)
      end
    end

    context 'with a mismatched email and password' do
      it 'returns nil' do
        expect(User.authenticate('example@test.com', '1234567')).to eq(nil)
      end
    end
  end

  describe '#password' do
    let!(:user) { User.create!(email: 'example@test.com', password: '12345') }
    let(:encrypted_password_hash) { BCrypt::Password.create(user.password) }

    it 'returns the an instance of BCrypt::Password' do
      expect(user.password.class).to eq(BCrypt::Password)
    end

    it 'returns a password hash that matches the original password string' do
      # == is patched on BCrypt::Password so that 60-char-encrypted-password == decoded password
      expect(user.password).to eq('12345')
    end
  end

  describe '#password=' do
    let!(:user) { User.create!(email: 'email@hi.com', password: '333') }

    it 'saves an ecrypted version of the password to the database' do
      expect(user.password_hash.size).to eq(60)
    end
  end
end
