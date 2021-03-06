class UserController < ApplicationController
  before_action :authenticate_user!, except: :rules

  def dashboard
    @presenter = Users::DashboardPresenter.new(current_user)
  end

  def leaderboard
    @users = User.all.includes(team: [flag_attachment: :blob]).to_a
    @presenter = Users::LeaderboardPresenter.new
    @groups = current_user.groups
    @leaderboards = @groups.each_with_object({}) do |group, leaderboard|
      leaderboard[group.id] = begin
        user_ranks = UserRank.where(group_id: group.id).order(points: :desc)
        user_ranks.map { |entry| [entry.user_id, entry.points, entry.rank, entry.change_in_rank] }
      end
    end
    @global_leaderboard = begin
      user_ranks = UserRank.where(group_id: 0).order(points: :desc)
      user_ranks.map { |entry| [entry.user_id, entry.points, entry.rank, entry.change_in_rank] }
    end
  end
end
