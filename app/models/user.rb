class User < ApplicationRecord

  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name

    'Anonymous'
  end

  def can_track_stock? symbol
    under_stock_limit? && !stock_already_tracked?(symbol)
  end

  def under_stock_limit?
    stocks.count < 10
  end

  def stock_already_tracked?(symbol)
    stock = Stock.check_db symbol
    return false unless stock

    stocks.where(id: stock.id).exists?
  end

  def filter_current_user(list)
    list.reject { |user| user.id == self.id }
  end

  def friends_with?(id)
    friends.where(id: id).exists?
  end

  def self.search(friend)
    friend = "%#{friend.strip}%"
    users = where('email LIKE ? OR first_name LIKE ? OR last_name LIKE ?', friend, friend, friend)
    return nil if users.empty?

    users
  end
end
