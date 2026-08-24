# Writes DRAFT Shipping, Refund and Terms policies.
#
#   .\tools\seed-policies.ps1              # dry run
#   .\tools\seed-policies.ps1 -Apply       # writes
#
# WHY THIS EXISTS: only PRIVACY_POLICY had content. The footer SUPPORT column
# already linked Shipping and Returns at /policies/*, so the live store carried
# two 404s, and the new POLICY column would have added two more.
#
# THESE ARE DRAFTS WRITTEN BY AN AI, NOT A LAWYER. Every one opens with a
# visible review banner. Removing that banner is a deliberate act that should
# follow legal review. It is on the pre-launch gate in docs/admin-tasks.md.
#
# PRIVACY_POLICY IS now rewritten too, on merchant instruction, to the Indian
# structure: SPI Rules 2011 consent, cookies, sharing, and a named Grievance
# Officer, which the IT Rules require and the previous version did not carry.
#
# Placeholders left ON PURPOSE, because inventing them would be worse than
# leaving them visible:
#   Pune   - the seat of courts for governing law
#   EMBRAE CARE   - the registered company behind EMBRAE
#   Rs379        - the flat fee under the free-shipping threshold
#   EMBRAE CARE, Venkatesh Graffiti Glover, Mundhwa, Pune - 411036, Maharashtra, India  - registered office, REQUIRED on both policies
#   Rajesh Gupta - REQUIRED by the IT Rules 2011 and E-Commerce Rules 2020
#   24 August 2026       - the date this is signed off

param([switch]$Apply)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

$THRESHOLD = "Rs599"
$SUPPORT_EMAIL = "care@embraecare.com"
$SUPPORT_PHONE = "+91 8600411991"

$BANNER = "<p><strong>DRAFT - NOT YET REVIEWED.</strong> This policy is a working draft prepared for internal review. It has not been checked by a legal advisor and is not yet binding. Do not publish the store to customers until this notice has been removed by someone qualified to remove it.</p>"

# ---------------------------------------------------------------------------
$SHIPPING = @"
$BANNER
<h2>Where we ship</h2>
<p>EMBRAE ships across India. We do not currently ship internationally.</p>

<h2>Dispatch</h2>
<p>Orders placed before 2:00 PM IST on a working day are dispatched within 24 working hours. Orders placed after that, or on a Sunday or public holiday, are dispatched on the next working day.</p>
<p>You will receive a tracking link by email and on WhatsApp once the parcel leaves our warehouse. Tracking can take up to 24 hours to begin updating after dispatch.</p>

<h2>Delivery time</h2>
<p>Once dispatched, typical delivery times are:</p>
<ul>
<li>Metro cities - 2 to 4 working days</li>
<li>Other cities and towns - 4 to 7 working days</li>
<li>Remote and difficult-to-serve pin codes - up to 10 working days</li>
</ul>
<p>These are estimates provided by our courier partners, not guarantees. Delivery may be delayed by weather, strikes, civic restrictions, festival volumes or other events outside our control. We will keep you informed if we are told of a delay.</p>

<h2>Shipping charges</h2>
<ul>
<li><strong>Free shipping on all orders over $THRESHOLD.</strong></li>
<li>Orders below $THRESHOLD carry a flat shipping fee of Rs379, shown at checkout before payment.</li>
</ul>
<p>The exact amount payable is always displayed on the checkout page before you confirm the order. Prices shown on the site are inclusive of GST.</p>

<h2>Address accuracy</h2>
<p>Please check your delivery address and phone number before confirming. We cannot change a delivery address once an order has been dispatched. If a parcel is returned to us because the address was incomplete or incorrect, or because nobody was available across the courier's delivery attempts, we will refund the order value but not the original shipping charge.</p>

<h2>If your parcel is delayed, lost or damaged</h2>
<p>If tracking has not updated for more than five working days, or the parcel arrives damaged, contact us within 48 hours of the delivery date shown by the courier. Please keep the outer packaging and send photographs - couriers require them to accept a claim.</p>
<p>Write to $SUPPORT_EMAIL or call $SUPPORT_PHONE.</p>

<h2>Questions</h2>
<p>Email $SUPPORT_EMAIL or call $SUPPORT_PHONE. We reply on working days.</p>
"@

# ---------------------------------------------------------------------------
$REFUND = @"
$BANNER
<h2>Our promise</h2>
<p>We pack every order by hand and check it before it leaves us. When something still goes wrong, we would rather fix it quickly than argue about it. This page sets out exactly what we will do, in which situations, and how long each one takes - so you know before you buy, not after.</p>

<h2>Cancelling an order</h2>
<ul>
<li>You can cancel any time <strong>before dispatch, or within 1 hour of placing the order</strong>, whichever comes first.</li>
<li>Orders cannot be cancelled in part. We are not able to remove individual items from an order once it is placed.</li>
<li>To cancel, write to $SUPPORT_EMAIL with your order number. A cancellation is only in effect once our team has confirmed it.</li>
<li>For prepaid orders cancelled inside that window, the refund is initiated within 24 to 48 working hours of the cancellation being processed.</li>
<li><strong>Orders cannot be cancelled after delivery.</strong> Skincare is a personal-care product and we cannot take it back into stock once it has left our control.</li>
</ul>

<h2>Returns</h2>
<p>We do not operate a general returns policy, and we want to be direct about why rather than bury it.</p>
<p>Skincare is a hygiene-sensitive category. Once a seal is broken we cannot verify how a product has been stored, and we will not resell it to someone else or destroy stock that a customer has paid for. So:</p>
<ul>
<li><strong>We do not accept returns of opened or used products.</strong></li>
<li><strong>We do not accept returns for change of mind.</strong></li>
</ul>
<p>Everything below is what we do instead, and in practice it covers the situations customers actually contact us about.</p>
<p>None of this affects your rights under the Consumer Protection Act, 2019 or any other law that applies to goods that are defective or not as described.</p>

<h2>Damaged on arrival</h2>
<ul>
<li>Report damage <strong>within 48 hours of delivery</strong>, with photographs of the product and its outer packaging.</li>
<li>Once our team has verified the damage, you receive a <strong>full refund or a replacement</strong>, whichever you prefer, at our cost.</li>
</ul>

<h2>Wrong or missing items</h2>
<ul>
<li>Report it <strong>within 48 hours of delivery</strong> and we will send the correct item or the missing one straight away.</li>
<li>An <strong>unboxing video is strongly recommended</strong>. It is the single thing that settles these cases fastest, and without it verification can take longer.</li>
</ul>

<h2>If a product has not worked for you</h2>
<p>Our formulations are dosed at percentages that need time. Most of them are designed to show a change over 4 to 8 weeks, not overnight.</p>
<p>If you have used a product consistently as directed for <strong>at least 7 days</strong> and feel it is doing nothing, write to us. One of our product advisors will go through your routine with you - most of the time the issue is layering, frequency or a conflicting active, and it is fixable without buying anything.</p>
<p>Where we agree the product was genuinely not right, we will issue a <strong>credit to the value of the product</strong> for use on a future order. We do not offer cash refunds in this situation, because the product has been used.</p>

<h2>If your skin reacts</h2>
<p>Skin can react unpredictably, and a reaction is not always a fault in the product.</p>
<ul>
<li><strong>Patch test before first use</strong>, particularly if your skin is sensitive or you have known allergies. Apply a small amount to the inner forearm and leave it 24 hours.</li>
<li>If a reaction occurs, <strong>stop using the product immediately</strong> and contact us with what happened, when, and what else was in your routine.</li>
<li>Follow the usage instructions on the carton. Several of our actives should not be layered with each other or used more often than stated.</li>
</ul>
<p>Two things we want to be honest about rather than leave you to discover:</p>
<ul>
<li><strong>We do not provide dermatological treatment or medical advice.</strong> If a reaction is severe, spreading, or does not settle, please see a doctor or a dermatologist.</li>
<li><strong>We do not offer monetary compensation</strong> beyond the value of the product concerned.</li>
</ul>

<h2>How refunds are paid</h2>
<p>Approved refunds are processed within 3 working days and issued to the original payment method. Your bank or card issuer then takes its own time to show it - usually 5 to 7 working days, sometimes longer. That part is outside our control.</p>
<p>Where an order used a discount that required a minimum order value, and a refund would take the order below that value, the discount is recalculated and the difference adjusted.</p>

<h2>Misuse</h2>
<p>EMBRAE CARE reserves the right to decline a transaction, or to hold a refund pending investigation, where an account shows a pattern of repeated cancellations, repeated damage claims, or chargebacks. This is aimed at a very small number of accounts and will never be applied to a genuine first-time claim.</p>

<h2>How to reach us</h2>
<p>Email $SUPPORT_EMAIL or call $SUPPORT_PHONE, with your order number. We reply on working days.</p>
"@

# ---------------------------------------------------------------------------
$TERMS = @"
$BANNER
<p><em>Last revised: 24 August 2026</em></p>

<p>THIS DOCUMENT IS AN ELECTRONIC RECORD IN TERMS OF THE INFORMATION TECHNOLOGY ACT, 2000 AND THE RULES ISSUED THEREUNDER, AND IS PUBLISHED IN ACCORDANCE WITH APPLICABLE LAW INCLUDING THE CONSUMER PROTECTION (E-COMMERCE) RULES, 2020. IT IS GENERATED BY A COMPUTER SYSTEM AND DOES NOT REQUIRE A PHYSICAL OR DIGITAL SIGNATURE.</p>

<p>Please read these Terms and Conditions carefully. By accessing, browsing or using this website, or by buying any EMBRAE product, you agree to be bound by them. This website and the products are operated and sold by EMBRAE CARE, GSTIN 27ATXPG8222A1ZN, trading as EMBRAE (referred to below as "we", "us" or "the Company"). If you do not agree to these terms, please do not use the site.</p>

<p>You are responsible for ensuring that your access to this site is lawful in the place from which you access it.</p>

<h2>1. Revision of these terms</h2>
<p>We may revise these terms at any time. A revised version takes effect from the moment it is published on this page, and your continued use of the site after that constitutes acceptance. Please review this page from time to time. The version published when you place an order is the version that governs that order.</p>
<p>We may suspend or permanently disable an account where we reasonably believe it has been used in breach of these terms or of fair use.</p>

<h2>2. Privacy</h2>
<p>Our Privacy Policy governs how we collect and handle your personal information, and forms part of these terms. Using this site means you have read and accepted it.</p>

<h2>3. Products</h2>
<p><strong>Terms of offer.</strong> The products offered on this site, including samples, trial sizes and free gifts, are for personal use only. You may not resell them without our written agreement. We may cancel or reduce the quantity of any order where we reasonably believe it would breach these terms.</p>
<p>We may change, suspend or discontinue any product at any time. Prices may change without notice.</p>
<p><strong>Accuracy.</strong> We describe our products, their ingredients and their concentrations as carefully as we can, and we publish concentrations rather than hiding them. Even so, this site may contain errors or omissions, including in pricing and availability. Photographs are indicative, and colour, texture and packaging may vary between batches and between screens.</p>
<p>We may correct errors at any time, including after an order has been placed. Where a correction affects an order you have already placed, we will contact you on your registered email or phone number and give you the choice of confirming at the corrected price or cancelling for a full refund.</p>
<p><strong>Communications.</strong> By placing an order or creating an account you agree to receive transactional messages from us by email, SMS, WhatsApp or phone. Marketing messages are sent only where you have opted in, and every one carries a way to opt out.</p>
<p><strong>Tax.</strong> Prices are inclusive of GST unless stated otherwise. You are responsible for any other tax that applies to your purchase.</p>

<h2>4. Eligibility</h2>
<p>You must be 18 years or older and capable of entering a binding contract under the Indian Contract Act, 1872. If you are under 18 you may use this site only with the involvement of a parent or guardian. You are responsible for all activity under any account you create.</p>

<h2>5. Your account</h2>
<p>You may hold one account. You are responsible for keeping your password confidential and for activity that occurs under your account. Accounts are not transferable and may not be sold, combined or shared.</p>
<p>If you believe your account has been accessed without your permission, contact us immediately using the details at the end of this page. We may require a password change, or suspend the account, where we believe its security has been compromised.</p>
<p>We may refuse service or terminate an account where these terms have been breached.</p>

<h2>6. Using this website</h2>
<p>You agree to use this site lawfully, and not to: interfere with other users' use of it; resell its content; send spam or unsolicited communications through it; or post anything unlawful, harassing, defamatory, obscene, deceptive or otherwise objectionable.</p>
<p>You are prohibited from attempting to breach the security of the site, including accessing data not intended for you, probing or scanning for vulnerabilities, attempting to overload or disrupt the service, or forging header information. Such attempts may result in civil or criminal liability.</p>
<p><strong>Licence.</strong> You are granted a limited, non-exclusive, non-transferable right to use the content on this site for your own personal, non-commercial purposes. You may not copy, reproduce, distribute or create derivative works from it without our written permission.</p>
<p><strong>Third-party links.</strong> Links to other websites are provided for convenience only. We do not endorse them and we are not responsible for their content or for any loss arising from your use of them. Read their own terms and privacy policies before using them.</p>

<h2>7. Content you submit</h2>
<p>By posting a review, photograph or other content, you confirm it is your own and accurate, and you grant us a worldwide, non-exclusive, royalty-free licence to use, display and reproduce it in connection with our products, subject to our Privacy Policy.</p>
<p>We may decline or remove content that is unlawful, misleading, offensive or unrelated. We are not liable for content submitted by users.</p>

<h2>8. Intellectual property</h2>
<p>The EMBRAE name, logo, product names, formulations, packaging, photography, text and site design are owned by or licensed to the Company and protected under Indian law. Nothing on this site grants you any right to use them.</p>

<h2>9. Cancellations, refunds and returns</h2>
<p>These are governed in full by our Refund Policy, which forms part of these terms. In summary:</p>
<ul>
<li>Orders may be cancelled before dispatch, or within 1 hour of being placed, whichever comes first. Partial cancellation is not possible.</li>
<li>Orders cannot be cancelled after delivery.</li>
<li>We do not accept returns of opened or used products, or returns for change of mind.</li>
<li>Damaged, wrong or missing items are replaced or refunded in full where reported within 48 hours of delivery.</li>
</ul>
<p>Damage caused by neglect, improper storage, or use contrary to the instructions on the pack is not covered.</p>
<p>Nothing in these terms limits your rights under the Consumer Protection Act, 2019 in respect of goods that are defective or not as described.</p>

<h2>10. Shipping and delivery</h2>
<p>Delivery timelines, charges and the free-shipping threshold are set out in our Shipping Policy. Risk in the products passes to you on delivery to the address you provided.</p>

<h2>11. Payment</h2>
<p>Payment may be made by credit card, debit card, net banking, UPI, wallets and, where offered, cash on delivery. Prepaid methods are processed instantly and are the fastest route to dispatch. Payments are handled by third-party providers; we do not store your card details.</p>

<h2>12. Disclaimer of warranties</h2>
<p>Your use of this site and of the products is at your own risk. Both are offered on an "as is" and "as available" basis. To the fullest extent permitted by law we disclaim all implied warranties, including merchantability and fitness for a particular purpose.</p>
<p>We do not warrant that the site will be uninterrupted or error-free, that the information on it is complete or current, or that any particular result will be obtained from using a product.</p>
<p><strong>Health disclaimer.</strong> Our products are cosmetics. They are not intended to diagnose, treat, cure or prevent any disease, and nothing on this site is medical advice. Results vary from person to person. If you are pregnant, breastfeeding, taking medication, undergoing dermatological treatment or have a known skin condition, consult a doctor before changing your routine.</p>
<p>Patch test before first use. Discontinue use and seek medical advice if irritation occurs. We are not responsible for outcomes arising from use contrary to the instructions on the pack, or from combining our products with others in ways we have not advised.</p>

<h2>13. Limitation of liability</h2>
<p>Nothing here limits liability that cannot be limited under Indian law, including for death or personal injury caused by negligence, or for fraud.</p>
<p>Subject to that, and to the fullest extent permitted by law, we are not liable for interruption of business, delays in accessing the site, loss or corruption of data, loss arising from third-party links, viruses or system failures, inaccuracies in content, or events beyond our reasonable control. We are not liable for indirect, special, punitive, incidental or consequential loss, including lost profits.</p>
<p>Our total aggregate liability in connection with any order will not exceed the amount you paid for that order.</p>
<p>Any claim arising from your use of this site must be brought within one year of the cause of action arising.</p>

<h2>14. Indemnity</h2>
<p>You agree to indemnify and hold harmless the Company, its directors, officers, employees and agents against any claim, loss or expense, including legal fees, arising from your breach of these terms or of any applicable law. This clause survives termination.</p>

<h2>15. Termination</h2>
<p>These terms remain in effect until terminated by you or by us. We may suspend or terminate your access at our discretion, without notice, where these terms have been breached. Termination does not cancel your obligation to pay for products already ordered.</p>

<h2>16. Force majeure</h2>
<p>We are not liable for delay or failure in performing our obligations where it results from events outside our reasonable control, including natural events, epidemic or pandemic, war, civil unrest, strikes, courier disruption, failures of public infrastructure or utilities, cyber attack, or any order or regulation of a government or judicial authority. Our obligations are suspended for the duration of such an event.</p>

<h2>17. Governing law, jurisdiction and arbitration</h2>
<p>These terms are governed by the laws of India. The courts at Pune have exclusive jurisdiction.</p>
<p>Any dispute arising out of these terms shall be referred to a sole arbitrator appointed by mutual agreement, under the Arbitration and Conciliation Act, 1996. The seat and venue of arbitration shall be Pune and the proceedings shall be in English. The decision of the arbitrator shall be final and binding.</p>
<p>Nothing in this clause prevents us from seeking injunctive or interim relief from any court of competent jurisdiction to protect our intellectual property or confidential information.</p>

<h2>18. General</h2>
<p>Nothing in these terms creates a partnership, agency or joint venture between us. A failure to enforce any provision is not a waiver of it. Headings are for convenience and do not affect interpretation.</p>
<p>If any provision is found invalid or unenforceable, it is replaced by a valid provision that most closely matches its intent, and the remainder of these terms continues in effect.</p>
<p>These terms are the entire agreement between you and the Company on their subject matter and supersede any prior understanding. We may cease operating the site and distributing the products at any time, at our discretion.</p>

<h2>19. Contact us</h2>
<ul>
<li>Email: $SUPPORT_EMAIL</li>
<li>Phone: $SUPPORT_PHONE</li>
<li>Hours: Monday to Saturday, 9:30 AM to 6:30 PM IST</li>
</ul>

<h2>20. Grievance Officer</h2>
<p>In accordance with the Information Technology Act, 2000 and the rules made thereunder, and the Consumer Protection (E-Commerce) Rules, 2020, the details of the Grievance Officer are:</p>
<ul>
<li>Name: Rajesh Gupta</li>
<li>Company: EMBRAE CARE</li>
<li>Address: EMBRAE CARE, Venkatesh Graffiti Glover, Mundhwa, Pune - 411036, Maharashtra, India</li>
<li>Email: $SUPPORT_EMAIL</li>
<li>Phone: $SUPPORT_PHONE</li>
<li>Hours: Monday to Friday, 9:30 AM to 6:30 PM IST</li>
</ul>
<p>Grievances are acknowledged within 48 hours and resolved within the timelines required by law.</p>
"@


# ---------------------------------------------------------------------------
$PRIVACY = @"
$BANNER
<p><em>Last revised: 24 August 2026</em></p>

<h2>Introduction</h2>
<p>This Privacy Policy explains what personal information EMBRAE collects, why we collect it, how we use and share it, and the choices you have. It applies to this website and to any order you place through it. The site is operated by EMBRAE CARE, trading as EMBRAE.</p>
<p>By using this site, creating an account, or giving us your information, you consent to the collection, use, storage and sharing of that information as described here. If you are using the site on behalf of someone else, you confirm you are authorised to accept this policy for them.</p>
<p>If this policy changes we will publish the revised version on this page. Please review it from time to time.</p>
<p>This policy does not cover third-party websites or services you reach from our site. We choose our service providers carefully, but we cannot be responsible for their practices. Read their policies before using them.</p>

<h2>What we collect</h2>
<p>You can browse this site without telling us who you are. Once you give us your information, you are no longer anonymous to us. Where a field is optional we say so, and you can always decline by choosing not to use that feature.</p>
<p><strong>Information you give us:</strong></p>
<ul>
<li>Name, email address, phone number and delivery address</li>
<li>Account username and password</li>
<li>Billing address and payment instrument details, handled by our payment providers</li>
<li>Order history and delivery preferences</li>
<li>Answers you give in the skin quiz, and any skin concerns you tell us about</li>
<li>Reviews, photographs, survey responses and messages you send us</li>
</ul>
<p><strong>Information we collect automatically:</strong></p>
<ul>
<li>The page you arrived from and the page you leave for</li>
<li>Browser and device information, and IP address</li>
<li>Pages viewed, products viewed and behaviour on the site, used in aggregate to understand how the site is performing</li>
</ul>

<h2>Sensitive personal information</h2>
<p>Some of what we collect - payment instrument details, passwords, and any information you volunteer about your skin - may be "sensitive personal data or information" under the Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011.</p>
<p>Collecting it requires your express consent, and by accepting this policy you give that consent. You may withdraw it by contacting us, though some services may then be unavailable to you.</p>
<p>Skin-quiz answers are used to recommend a routine. They are <strong>not</strong> medical records, we do not treat them as a diagnosis, and we do not share them with advertisers.</p>

<h2>Cookies</h2>
<p>We use cookies and similar technologies to keep your cart and session working, to remember preferences so you sign in less often, and to understand how pages perform. You can disable cookies in your browser and still use the site, though some features will not work properly. We do not control cookies set by third parties on some pages.</p>

<h2>How we use your information</h2>
<ul>
<li>To process, pack, ship and support your orders</li>
<li>To operate your account and keep it secure</li>
<li>To answer your questions and handle complaints and returns</li>
<li>To recommend products and routines, including from your quiz answers</li>
<li>To improve the site, our products and our service</li>
<li>To meet our legal, tax and regulatory obligations</li>
<li>To detect and prevent fraud and misuse</li>
</ul>

<h2>Messages you receive from us</h2>
<p><strong>Service messages.</strong> Order confirmations, dispatch and delivery updates, and replies to your questions. These are necessary to serve you and are sent regardless of marketing preferences.</p>
<p><strong>Email.</strong> If you give us your email address we may send newsletters, product and ingredient information, skincare guidance, surveys and offers. Every marketing email carries an unsubscribe link, and you can also change your preferences in your account.</p>
<p><strong>SMS and WhatsApp.</strong> If you give us your mobile number you may receive order updates and, where you have opted in, product news and offers. We do not send unsolicited marketing messages. We charge nothing for these, but your mobile operator may apply its own charges.</p>
<p><strong>Phone calls.</strong> We may call you about an order, a delivery problem or a question you have raised.</p>

<h2>When we share information</h2>
<p><strong>We do not sell or rent your personal information to anyone for their own marketing.</strong></p>
<p>We share it only where it is needed:</p>
<ul>
<li>With service providers who make our service work - payment gateways, courier and logistics partners, email and messaging providers, review platforms and analytics providers. They are bound by contract to keep it confidential and to use it only for what we have asked them to do.</li>
<li>Where we are required to by law, regulation, court order or a governmental authority.</li>
<li>To establish or exercise our legal rights, to recover a debt, to process an insurance claim, or to prevent harm.</li>
<li>If the business is merged, acquired, or its assets are sold, in which case your information may transfer as part of that transaction.</li>
</ul>

<h2>Keeping information secure</h2>
<p>We take reasonable technical and organisational measures to protect your information against unauthorised access, alteration, disclosure or destruction. Access is limited to the people and providers who need it to operate or improve our service.</p>
<p>No method of transmission or storage is completely secure, so we cannot guarantee absolute security. If we become aware of a breach affecting your information, we will act on it and notify you where the law requires.</p>

<h2>How long we keep it</h2>
<p>We keep order and transaction records for as long as tax and company law requires. Account and marketing information is kept while your account is active, and for a reasonable period afterwards to handle disputes and enforce our agreements.</p>

<h2>Your choices, and correcting your information</h2>
<p>You may access, correct or update your information from your account, or by contacting us at $SUPPORT_EMAIL or $SUPPORT_PHONE. You can unsubscribe from marketing at any time, and you may ask us to delete your information where we are not required to keep it.</p>
<p>You are responsible for the accuracy of what you give us. If information you provide is untrue, inaccurate or incomplete - or we have reasonable grounds to believe it is - we may decline to provide services.</p>

<h2>Children</h2>
<p>This site is not intended for anyone under 18. We do not knowingly collect information from children. If you believe a child has given us information, contact us and we will delete it.</p>

<h2>Content you post publicly</h2>
<p>Where the site lets you post reviews or messages that others can see, anything you post there can be collected and used by other people. Other users are not our representatives and their statements are not ours. We are not liable for how information you make public is used.</p>

<h2>Grievance Officer</h2>
<p>In accordance with the Information Technology Act, 2000 and the Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011, the name and contact details of the Grievance Officer are:</p>
<ul>
<li>Name: Rajesh Gupta</li>
<li>Company: EMBRAE CARE</li>
<li>Address: EMBRAE CARE, Venkatesh Graffiti Glover, Mundhwa, Pune - 411036, Maharashtra, India</li>
<li>Email: $SUPPORT_EMAIL</li>
<li>Phone: $SUPPORT_PHONE</li>
<li>Hours: Monday to Friday, 9:30 AM to 6:30 PM IST</li>
</ul>
<p>Grievances are acknowledged within 48 hours and resolved within the timelines required by law.</p>
"@

# ---------------------------------------------------------------------------
$POLICIES = @(
  @{ type = "PRIVACY_POLICY";  label = "Privacy Policy";   body = $PRIVACY }
  @{ type = "SHIPPING_POLICY"; label = "Shipping Policy";  body = $SHIPPING }
  @{ type = "REFUND_POLICY";   label = "Refund Policy";    body = $REFUND }
  @{ type = "TERMS_OF_SERVICE"; label = "Terms of Service"; body = $TERMS }
)

$mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
Write-Output "=== EMBRAE policies - $mode ==="
Write-Output "All four policies are written, including PRIVACY_POLICY."
Write-Output ""

foreach ($p in $POLICIES) {
  Write-Output ("  {0,-18} {1,6} chars" -f $p.type, $p.body.Length)
  if ($Apply) {
    $vars = @{ shopPolicy = @{ type = $p.type; body = $p.body } }
    $r = Send-GQL 'mutation($shopPolicy:ShopPolicyInput!){ shopPolicyUpdate(shopPolicy:$shopPolicy){ shopPolicy{ id type url } userErrors{ code field message } } }' $vars
    Show-GQLErrors $r $p.type
    if ($r.data.shopPolicyUpdate.userErrors) { $r.data.shopPolicyUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
    elseif ($r.data.shopPolicyUpdate.shopPolicy) { Write-Output ("      -> " + $r.data.shopPolicyUpdate.shopPolicy.url) }
  }
}

Write-Output ""
if ($Apply) {
  Write-Output "WRITTEN AS DRAFTS. Each carries a visible review banner."
  Write-Output "Placeholders left on purpose, all REQUIRED before launch:"
  Write-Output "  EMBRAE CARE EMBRAE CARE, Venkatesh Graffiti Glover, Mundhwa, Pune - 411036, Maharashtra, India Rajesh Gupta"
  Write-Output "  Pune Rs379 24 August 2026"
  Write-Output ""
  Write-Output "If PRIVACY_POLICY failed on automatic management being turned on:"
  Write-Output "  Shopify Admin > Settings > Policies > Privacy policy > turn OFF automatic"
  Write-Output "  management, then re-run. The API cannot override that toggle."
} else {
  Write-Output "Nothing was written. Re-run with -Apply."
}
