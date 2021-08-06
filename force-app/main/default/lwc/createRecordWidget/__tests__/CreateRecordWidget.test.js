// npm run test:unit
import { createElement } from 'lwc';
import CreateRecordWidget from 'c/CreateRecordWidget';
import { checkValueHelper } from 'c/createRecordWidget';


const nestedString = '{[( Properly Nested String)]}';
const notNestedString = '[({ Not Properly Nested String)]}';


describe('c-create-record component', () => {
  beforeEach(()=>{
    const element = createElement('c-create-record-component', {
      is:CreateRecordWidget
    })
    document.body.appendChild(element)
  })

  test('display Title Add Widget Record', ()=>{
    const element = document.querySelector('c-create-record-component')
    const text = element.shadowRoot.querySelector('div.slds-text-body_regular')
    expect(text.textContent).toBe('Assessment Task')
  })

  test('display Button Add Widget Record', ()=>{
    const element = document.querySelector('c-create-record-component')
    const btn = element.shadowRoot.querySelector('lightning-button')
    expect(btn.label).toBe('Add Widget Record')
  })

})
