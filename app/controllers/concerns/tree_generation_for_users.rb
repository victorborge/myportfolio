module TreeGenerationForUsers
  extend ActiveSupport::Concern

  def team_for(user)
    root = user.hash_tree(limit_depth: 6)
    transform_node root
  end

  protected

  def transform_node node
    node.map do |key, value|
      {
          admin_url: admin_user_path(key.id),
          username: key.member_id,
          name: key.full_name,
          email: key.email,
          children: transform_node(value)
      }
    end
  end
end