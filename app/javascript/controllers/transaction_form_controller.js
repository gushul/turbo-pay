import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "amountError"]
  static values = { availableAmount: Number }

  connect() {
    this.updateAvailableAmount()
  }

  updateAvailableAmount() {
    const accountSelect = this.element.querySelector("#transaction_sender_account_id")
    const option = accountSelect.selectedOptions[0]
    const balance = option.text.match(/\((.*?)\)/)[1]
    this.availableAmountValue = parseFloat(balance.replace(/[^0-9.-]+/g, ""))
  }

  validateAmount(event) {
    const amount = parseFloat(event.target.value)
    
    if (amount > this.availableAmountValue) {
      this.amountErrorTarget.textContent = "Amount exceeds available balance"
      this.amountErrorTarget.classList.remove("hidden")
      this.submitTarget.disabled = true
    } else if (amount <= 0) {
      this.amountErrorTarget.textContent = "Amount must be positive"
      this.amountErrorTarget.classList.remove("hidden")
      this.submitTarget.disabled = true
    } else {
      this.amountErrorTarget.classList.add("hidden")
      this.submitTarget.disabled = false
    }
  }

  validate(event) {
    if (this.submitTarget.disabled) {
      event.preventDefault()
    }
  }
}
