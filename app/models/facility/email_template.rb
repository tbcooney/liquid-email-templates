class Facility::EmailTemplate
  include ActiveModel::Model

  attr_accessor :id, :account_id, :facility_id, :name, :title, :body_html

  class Template
    include ActiveModel::Model

    attr_accessor :id, :name, :code

    def self.model_name
      ActiveModel::Name.new(Facility::EmailTemplate)
    end

    TEMPLATES =
      [{
        "key": "10",
        "name": "Order confirmation",
        "title": "Order confirmation reminder",
        "code": "order_confirmation",
        "description": "When the order is created, send this email to the customer"
      },{
        "key": "11",
        "name": "Dunning reminder",
        "code": "dunning_reminder",
        "description": "When the order is created, send this email to the customer"
      }]

    def self.find(id)
      field = TEMPLATES.find {|template| template[:code] == id.to_s }
      new(id: id, code: field[:code], name: field[:name])
    end

    def to_param
      code
    end

    def body_html
      body = Rails.cache.fetch "openunit_templates_emails_#{self.code}_body" do
        File.read(Rails.root.join("app/views/admin/facilities/templates/emails/#{self.code}_body.liquid"))
      end
    end

    def title
      title = Rails.cache.fetch "openunit_templates_emails_#{self.code}_title" do
        File.read(Rails.root.join("app/views/admin/facilities/templates/emails/#{self.code}_title.liquid"))
      end
    end

    def render(assigns = {})
      assigns = assigns

      result = {
        subject: template_subject.render(assigns),
        body: template_body.render(assigns)
      }.compact
    end

    def template_body
      Liquid::Template.parse(body_html)
    end

    def template_subject
      Liquid::Template.parse(title)
    end
  end

  def to_param
    name.parameterize(separator: "_")
  end

  private

    def template_body
      Liquid::Template.parse(body)
    end

    def template_subject
      Liquid::Template.parse(subject)
    end
end
