# -*- encoding : utf-8 -*-
class User < ApplicationRecord
  extend FriendlyId
  friendly_id :nickname

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  bitmask :access_level, :as => [:player, :organizer, :admin]
  belongs_to :team
  has_many :created_games, :class_name => "Game", :foreign_key => "author_id"
  mount_uploader :avatar, UserAvatarUploader

  before_create :set_default_access_level
  validates_presence_of :email, :message => "Не введён e-mail"

  validates_uniqueness_of :email,
    :message => "Пользователь с таким адресом уже зарегистрирован"

  validates_presence_of :nickname,
    :message => "Вы не ввели имя"

  validates_uniqueness_of :nickname,
    :message => "Пользователь с таким именем уже зарегистрирован"

  scope :without_team, -> { where(team_id: nil) }

  def self.free_players
    self.without_team
  end

  def member_of_any_team?
    !! team
  end

  def captain?
    member_of_any_team? && captain_of?(team)
  end

  def author_of?(game)
    game.author.id == self.id
  end

  def captain_of?(other_team)
    other_team.captain.id == id
  end

  def can_edit?(game)
    self.author_of?(game) || self.access_level?(:admin)
  end

  def get_access_level_label
    if self.access_level?(:admin) then return 'Администратор' end
    if self.access_level?(:organizer) then return 'Организатор' end
    if self.access_level?(:player) then return 'Игрок' end
  end

  def should_generate_new_friendly_id?
    nickname_changed? || super
  end

  private

  def set_default_access_level
    self.access_level << :organizer
  end
end
