class ActionDispatch::Routing::Mapper
  def anypresence_extension_lifecycle_triggered_action(*resources)
    resources.each do |r|
      AnypresenceExtension::Engine.routes.draw do
        post "perform" => r
      end
      Rails.application.routes.draw do
        post "perform" => r
      end
    end
  end
end