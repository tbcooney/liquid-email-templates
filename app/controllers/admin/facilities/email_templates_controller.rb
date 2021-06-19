module Admin
  module Facilities
    class EmailTemplatesController < Admin::Facilities::ApplicationController
      before_action :email_template, except: [:index, :create]

      def index
      end

      def create
        @email_template = @facility.email_templates.create(email_template_params)
        @email_template.account = @facility.account

        if @email_template.save
          redirect_to edit_admin_facility_settings_facility_email_template_path(@facility, @email_template.name.parameterize(separator: "_"))
        end
      end

      def edit
      end

      def update
        if @email_template.update(email_template_params)
          flash[:notice] = "Template saved successfully"
          redirect_to edit_admin_facility_settings_facility_email_template_path(@facility, @email_template)
        end
      end

      def destroy
        @email_template.destroy
        redirect_to edit_admin_facility_settings_facility_email_template_path
      end

      private

      def email_template_params
        params.require(:facility_email_template).permit(
          :name,
          :title,
          :body_html
        )
      end

      def email_template
        @email_template = @facility.email_templates.find_by_name(params[:id]) || Facility::EmailTemplate::Template.find(params[:id])
      end
    end
  end
end
