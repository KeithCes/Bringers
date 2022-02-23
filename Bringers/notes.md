# stuff to do soon
- make refund orderer + bringer payout one transaction to prevent partial completions on error
- handle refunds on order cancels
- use stripe native credit card add form instead of plain text
- texting/calling support
- TESTING!!!!
- allow decimals for actual item price bringerconfirm
- add number of orders/bringers placed/completed/cancelled
- add rating after order
- add address to your profile for editting
- update stripe when users name/email/phone changed

# shit to do if bored
- TESTING!!!!
- modeulate dropdown (state createacc, pickupbuy placeorder)
- modulate network calls (own classes) 
- modulate dropdown (state createacc, pickupbuy placeorder)
- supposed to use getToken() instead of uid for authing; less secure? later problem...
- editing yourprofile and then going to placeorder acts like keyboard is still up for a second
- placeholder for profile picture looks a bit janky, design a better one and replace on youprofile and map views

# stuff to add later

- send email receipt of transaction on completion
- handle card declined case for orders
- our db rules are non-existant, should probably add some
- probably need auth headers for all HTTP calls so someone can't remotely do stuff (SECURITY)
- when email is changed the email is only changed in db not auth (login uses creation email)
- slight flickering of keyboard when password fields selected (create)
- item name/description on confirmation screen
- seperate all logic from view into viewmodel
- views get funky on very small screen sizes (ipod touch, iphone 8, iphone se)
- databse rules: make user unable to read email, phone number from other users
- custom cropping profile picture
- add push notifications for bringer coming/order complete/etc
- map could be bigger on large devices (ipad especially)
- if no orders on bringerorderview stop infintie loading and display message
