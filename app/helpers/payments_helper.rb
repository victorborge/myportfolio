module PaymentsHelper

  def submit_button(plan_type, plan_scheme)
    button_to 'Pay With PayPal', payments_path(plan_type: plan_type, plan_scheme: plan_scheme), class: 'btn btn-link'
  end

  def purchase_button(plan_type)
    if current_user.current_plan == plan_type
      button_to 'Cancel', payments_path, method: :delete, data: { confirm: "Are you sure? This will permanently cancel your plan." }, class: 'btn btn-link'
    else
      raw <<-EOS
        <button type="button" class="btn btn-link" data-toggle="modal" data-target="##{plan_type}Modal">
          #{purchase_button_text}
        </button>
      EOS
    end
  end

  def purchase_modal(plan_type)
    raw <<-EOS
      <div class="modal fade" id="#{plan_type}Modal" tabindex="-1" role="dialog" aria-labelledby="#{plan_type}ModalLabel">
        <div class="modal-dialog modal-lg" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 class="modal-title" id="#{plan_type}ModalLabel">Choose Package Scheme</h4>
            </div>
            <div class="modal-body">
              <div class="row">
                <div class="col-md-4 col-md-push-2">
                  <div class="tribox">
                    <div class="tribox-section tribox-top">
                      <span class="tribox-main-content">SAVE MORE</span>
                      <span class="tribox-sub-content">YEARLY PLAN</span>
                    </div>
                    <div class="tribox-section tribox-mid">
                      <span class="tribox-main-content">$#{Setting["plans.#{plan_type}.pricing.yearly"]}</span>
                      <span class="tribox-sub-content">1 Time Payment</span>
                    </div>
                    <div class="tribox-section tribox-btm">
                      #{submit_button(plan_type, 'yearly')}
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-md-push-2">
                  <div class="tribox">
                    <div class="tribox-section tribox-top">
                      <span class="tribox-main-content">PAY AS YOU GO</span>
                      <span class="tribox-sub-content">MONTHLY PLAN</span>
                    </div>
                    <div class="tribox-section tribox-mid">
                      <span class="tribox-main-content">$#{Setting["plans.#{plan_type}.pricing.monthly"]}</span>
                      <span class="tribox-sub-content">Monthly Payment</span>
                    </div>
                    <div class="tribox-section tribox-btm">
                      #{submit_button(plan_type, 'monthly')}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    EOS
  end

  private

  def purchase_button_text
    if current_user.current_plan.present?
      'Change Plan'
    else
      'Purchase'
    end
  end

end
