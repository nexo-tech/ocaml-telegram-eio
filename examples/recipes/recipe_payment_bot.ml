(** Recipe: Payment Bot

    A comprehensive payment system demonstrating:
    - Invoice creation and sending with LabeledPrice
    - Creating shareable payment links
    - Product catalog with multiple items
    - Shipping query handling with options
    - Pre-checkout query validation
    - Successful payment processing
    - Order fulfillment tracking
    - Stars refunds
    - Payment provider integration
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Product Catalog} *)

type product = {
  id : string;
  name : string;
  description : string;
  price_cents : int64;  (* Price in smallest currency unit *)
  currency : string;
  emoji : string;
  requires_shipping : bool;
}

module ProductCatalog = struct
  let products = [
    {
      id = "prod_basic";
      name = "Basic Plan";
      description = "1-month access to basic features";
      price_cents = 999L;  (* $9.99 *)
      currency = "USD";
      emoji = "📦";
      requires_shipping = false;
    };
    {
      id = "prod_pro";
      name = "Pro Plan";
      description = "1-month access to all premium features";
      price_cents = 1999L;  (* $19.99 *)
      currency = "USD";
      emoji = "⭐";
      requires_shipping = false;
    };
    {
      id = "prod_shirt";
      name = "T-Shirt";
      description = "Limited edition branded t-shirt";
      price_cents = 2500L;  (* $25.00 *)
      currency = "USD";
      emoji = "👕";
      requires_shipping = true;
    };
    {
      id = "prod_sticker";
      name = "Sticker Pack";
      description = "Collection of 10 premium stickers";
      price_cents = 499L;  (* $4.99 *)
      currency = "USD";
      emoji = "🎨";
      requires_shipping = true;
    };
  ]

  let find id =
    Flo.debugf "[ProductCatalog] Looking up product: id=%s" id;
    match List.find_opt (fun p -> String.equal p.id id) products with
    | Some p ->
        Flo.successf "[ProductCatalog] ✅ Found product: %s - $%.2f"
          p.name (Int64.to_float p.price_cents /. 100.0);
        Some p
    | None ->
        Flo.errorf "[ProductCatalog] ❌ Product not found: id=%s" id;
        None

  let _list_all () =
    Flo.debugf "[ProductCatalog] Listing all products: count=%d" (List.length products);
    products

  let format_catalog () =
    let lines = List.map (fun p ->
      let price = Int64.to_float p.price_cents /. 100.0 in
      Printf.sprintf "%s <b>%s</b> - $%.2f\n%s\nShipping: %s"
        p.emoji p.name price p.description
        (if p.requires_shipping then "Yes" else "No")
    ) products in
    String.concat "\n\n" lines
end

(** {1 Order Management} *)

type order_status =
  | Pending
  | AwaitingPayment
  | Paid
  | Fulfilled
  | Refunded [@warning "-37"]

module OrderManager = struct
  type order = {
    order_id : string;
    product_id : string;
    user_id : Id.User.k Id.t;
    _chat_id : Id.Chat.k Id.t;
    status : order_status;
    total_amount : int64;
    _currency : string;
    _telegram_charge_id : string option;
    _provider_charge_id : string option;
    _created_at : float;
  }

  let orders : (string, order) Hashtbl.t = Hashtbl.create 100

  let create ~product_id ~user_id ~chat_id =
    let order_id = Printf.sprintf "order_%d_%f" (Random.int 1000000) (Unix.time ()) in

    match ProductCatalog.find product_id with
    | None ->
        Flo.errorf "[OrderManager] ❌ Cannot create order, product not found: %s" product_id;
        Error (Error.Internal_error "Product not found")
    | Some product ->
        let order = {
          order_id;
          product_id;
          user_id;
          _chat_id = chat_id;
          status = Pending;
          total_amount = product.price_cents;
          _currency = product.currency;
          _telegram_charge_id = None;
          _provider_charge_id = None;
          _created_at = Unix.time ();
        } in

        Hashtbl.replace orders order_id order;
        Flo.successf "[OrderManager] ✅ Created order: order_id=%s, product=%s, amount=%Ld"
          order_id product_id product.price_cents;
        Ok order

  let find order_id =
    Flo.debugf "[OrderManager] Looking up order: order_id=%s" order_id;
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        Flo.successf "[OrderManager] ✅ Found order: status=%s"
          (match order.status with
           | Pending -> "Pending"
           | AwaitingPayment -> "AwaitingPayment"
           | Paid -> "Paid"
           | Fulfilled -> "Fulfilled"
           | Refunded -> "Refunded");
        Some order
    | None ->
        Flo.error "[OrderManager] ❌ Order not found";
        None

  let update_status order_id status =
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        let updated = { order with status } in
        Hashtbl.replace orders order_id updated;
        Flo.successf "[OrderManager] ✅ Updated order status: order_id=%s, new_status=%s"
          order_id
          (match status with
           | Pending -> "Pending"
           | AwaitingPayment -> "AwaitingPayment"
           | Paid -> "Paid"
           | Fulfilled -> "Fulfilled"
           | Refunded -> "Refunded");
        Ok ()
    | None ->
        Flo.errorf "[OrderManager] ❌ Cannot update, order not found: %s" order_id;
        Error (Error.Internal_error "Order not found")

  let mark_paid ~order_id ~telegram_charge_id ~provider_charge_id =
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        let updated = {
          order with
          status = Paid;
          _telegram_charge_id = Some telegram_charge_id;
          _provider_charge_id = Some provider_charge_id;
        } in
        Hashtbl.replace orders order_id updated;
        Flo.successf "[OrderManager] ✅ Marked order as paid: order_id=%s, telegram_charge=%s"
          order_id telegram_charge_id;
        Ok updated
    | None ->
        Flo.errorf "[OrderManager] ❌ Cannot mark paid, order not found: %s" order_id;
        Error (Error.Internal_error "Order not found")

  let get_user_orders user_id =
    Flo.debugf "[OrderManager] Getting orders for user: user_id=%s" (Format.asprintf "%a" Id.pp user_id);
    let user_orders = Hashtbl.fold (fun _ order acc ->
      if Id.to_string order.user_id = Id.to_string user_id then order :: acc else acc
    ) orders [] in
    Flo.debugf "[OrderManager] Found %d orders for user" (List.length user_orders);
    user_orders
end

(** {1 Price Helpers} *)

module PriceHelper = struct
  let price ~label ~amount =
    Flo.debugf "[PriceHelper] Creating price: label='%s', amount=%Ld" label amount;
    Telegram_generated.Gen_types.LabeledPrice.{
      label;
      amount;
      unknown_fields = [];
    }

  let product_prices product =
    Flo.debugf "[PriceHelper] Creating prices for product: %s" product.name;
    [
      price ~label:product.name ~amount:product.price_cents;
    ]

  let with_tax prices tax_rate =
    let total = List.fold_left (fun acc p ->
      Int64.add acc p.Telegram_generated.Gen_types.LabeledPrice.amount
    ) 0L prices in
    let tax_amount = Int64.div (Int64.mul total (Int64.of_int (int_of_float (tax_rate *. 100.0)))) 10000L in

    if tax_amount > 0L then begin
      Flo.debugf "[PriceHelper] Adding tax: total=%Ld, tax=%Ld (%.1f%%)"
        total tax_amount (tax_rate *. 100.0);
      prices @ [price ~label:"Tax" ~amount:tax_amount]
    end else
      prices
end

(** {1 Shipping Options} *)

module ShippingHelper = struct
  let shipping_option ~id ~title ~amount =
    Flo.debugf "[ShippingHelper] Creating shipping option: id=%s, title='%s', amount=%Ld"
      id title amount;

    let open Telegram_generated.Gen_types in
    ShippingOption.{
      id;
      title;
      prices = [LabeledPrice.{ label = title; amount; unknown_fields = [] }];
      unknown_fields = [];
    }

  let standard = shipping_option ~id:"standard" ~title:"Standard Shipping" ~amount:500L  (* $5.00 *)
  let express = shipping_option ~id:"express" ~title:"Express Shipping" ~amount:1500L  (* $15.00 *)
  let international = shipping_option ~id:"international" ~title:"International" ~amount:2500L  (* $25.00 *)

  let get_available_options (address : Telegram_generated.Gen_types.ShippingAddress.t) =
    Flo.debugf "[ShippingHelper] Determining shipping options for: country=%s, city=%s"
      address.country_code
      address.city;

    (* Simple logic: different options based on country *)
    match address.country_code with
    | "US" ->
        Flo.success "[ShippingHelper] ✅ US address: standard and express available";
        Ok [standard; express]
    | "CA" | "MX" ->
        Flo.success "[ShippingHelper] ✅ North America: standard and international available";
        Ok [standard; international]
    | _ ->
        Flo.success "[ShippingHelper] ✅ International address: international shipping only";
        Ok [international]
end

(** {1 Payment Provider Configuration} *)

module PaymentProvider = struct
  let get_provider_token () =
    match Sys.getenv_opt "PAYMENT_PROVIDER_TOKEN" with
    | Some token ->
        Flo.success "[PaymentProvider] ✅ Loaded provider token from environment";
        Ok token
    | None ->
        Flo.debug "[PaymentProvider] ⚠️  No PAYMENT_PROVIDER_TOKEN set, using test token";
        (* Test token for Telegram's test payment provider *)
        Ok "284685063:TEST:YjEwMjZhN2Y2ZmJh"

  let supports_stars = ref false

  let enable_stars () =
    supports_stars := true;
    Flo.success "[PaymentProvider] ✅ Stars payments enabled"

  let _is_stars_payment currency =
    String.equal (String.uppercase_ascii currency) "XTR"
end

(** {1 Command Handlers} *)

let handle_start ctx _args =
  Flo.debug "[Handler] /start command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  Flo.debugf "[Handler] User: id=%s, username=%s"
    (Format.asprintf "%a" Id.pp user.id)
    (match user.username with Some u -> u | None -> "none");

  let welcome_text =
    "💳 <b>Payment Bot</b>\n\n\
     Welcome to our store! I can help you make purchases.\n\n\
     <b>Commands:</b>\n\
     /products - Browse available products\n\
     /buy &lt;product_id&gt; - Purchase a product\n\
     /orders - View your order history\n\
     /help - Show help information"
  in

  let* _msg = answer ctx welcome_text in
  Flo.success "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_products ctx _args =
  Flo.debug "[Handler] /products command triggered";
  let open Bot.Ctx in

  let catalog = ProductCatalog.format_catalog () in
  let products_text =
    "🛍️ <b>Available Products</b>\n\n" ^ catalog ^
    "\n\nUse /buy &lt;product_id&gt; to purchase."
  in

  let* _msg = answer ctx products_text in
  Flo.success "[Handler] ✅ Products list sent";
  Ok ()

let handle_buy ctx args =
  Flo.debugf "[Handler] /buy command triggered with args: [%s]"
    (String.concat " " args);

  let open Bot.Ctx in

  let client = client ctx in
  let chat_id = chat ctx in
  let* user = require_user ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /buy <product_id>\n\nUse /products to see available items." in
      Ok ()
  | product_id :: _ ->
      (match ProductCatalog.find product_id with
       | None ->
           let* _ = answer ctx "❌ Product not found. Use /products to see available items." in
           Ok ()
       | Some product ->
           Flo.debugf "[Handler] Creating order for product: %s" product.name;

           (* Create order *)
           let* order = OrderManager.create ~product_id ~user_id:user.id ~chat_id in

           (* Get provider token *)
           let* provider_token = PaymentProvider.get_provider_token () in

           (* Create prices *)
           let prices = PriceHelper.product_prices product in
           let prices_with_tax = PriceHelper.with_tax prices 0.08 in  (* 8% tax *)

           Flo.debugf "[Handler] Sending invoice: order_id=%s, product=%s"
             order.order_id product.name;

           (* Send invoice *)
           let* _invoice_msg = Telegram_generated.Gen_methods.send_invoice client
             ~chat_id
             ~title:product.name
             ~description:product.description
             ~payload:order.order_id  (* Use order_id as payload *)
             ~currency:product.currency
             ~prices:prices_with_tax
             ~provider_token
             ~max_tip_amount:1000L  (* Max $10 tip *)
             ~suggested_tip_amounts:[100L; 300L; 500L; 1000L]
             ~need_name:true
             ~need_email:(not product.requires_shipping)
             ~need_shipping_address:product.requires_shipping
             ~is_flexible:product.requires_shipping  (* Allow shipping options *)
             ()
           in

           let* () = OrderManager.update_status order.order_id AwaitingPayment in

           Flo.success "[Handler] ✅ Invoice sent successfully";
           Ok ()
      )

let handle_link ctx args =
  Flo.debug "[Handler] /link command triggered";
  let open Bot.Ctx in

  let client = client ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /link <product_id>" in
      Ok ()
  | product_id :: _ ->
      (match ProductCatalog.find product_id with
       | None ->
           let* _ = answer ctx "❌ Product not found." in
           Ok ()
       | Some product ->
           let* provider_token = PaymentProvider.get_provider_token () in

           let prices = PriceHelper.product_prices product in

           Flo.debugf "[Handler] Creating payment link for: %s" product.name;

           let* link_json = Telegram_generated.Gen_methods.create_invoice_link client
             ~title:product.name
             ~description:product.description
             ~payload:(Printf.sprintf "link_%s_%f" product_id (Unix.time ()))
             ~currency:product.currency
             ~prices
             ~provider_token
             ()
           in

           (* Extract string from JSON response *)
           let link = match link_json with
             | `String s -> s
             | _ -> Yojson.Safe.to_string link_json
           in

           let link_text = Printf.sprintf
             "💳 <b>Payment Link</b>\n\n\
              Product: %s\n\
              Price: $%.2f\n\n\
              <a href=\"%s\">Click here to pay</a>"
             product.name
             (Int64.to_float product.price_cents /. 100.0)
             link
           in

           let* _msg = answer ctx link_text in
           Flo.success "[Handler] ✅ Payment link sent";
           Ok ()
      )

let handle_orders ctx _args =
  Flo.debug "[Handler] /orders command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in

  let user_orders = OrderManager.get_user_orders user.id in

  if List.length user_orders = 0 then begin
    let* _msg = answer ctx "📦 You have no orders yet.\n\nUse /products to browse items." in
    Ok ()
  end else begin
    let order_lines = List.map (fun order ->
      let status_str = match order.OrderManager.status with
        | Pending -> "⏳ Pending"
        | AwaitingPayment -> "💳 Awaiting Payment"
        | Paid -> "✅ Paid"
        | Fulfilled -> "📦 Fulfilled"
        | Refunded -> "💸 Refunded"
      in

      let product_name = match ProductCatalog.find order.product_id with
        | Some p -> p.name
        | None -> "Unknown Product"
      in

      Printf.sprintf "<b>Order %s</b>\n%s - $%.2f\nStatus: %s"
        (String.sub order.order_id 0 (min 8 (String.length order.order_id)))
        product_name
        (Int64.to_float order.total_amount /. 100.0)
        status_str
    ) user_orders in

    let orders_text =
      "📦 <b>Your Orders</b>\n\n" ^
      String.concat "\n\n" order_lines
    in

    let* _msg = answer ctx orders_text in
    Flo.successf "[Handler] ✅ Orders list sent: count=%d" (List.length user_orders);
    Ok ()
  end

let handle_help ctx _args =
  Flo.debug "[Handler] /help command triggered";
  let open Bot.Ctx in

  let help_text =
    "💳 <b>Payment Bot Help</b>\n\n\
     This bot demonstrates Telegram Payments integration.\n\n\
     <b>Available Commands:</b>\n\
     /products - Browse product catalog\n\
     /buy &lt;product_id&gt; - Purchase a product\n\
     /link &lt;product_id&gt; - Get shareable payment link\n\
     /orders - View your order history\n\
     /help - Show this message\n\n\
     <b>Payment Flow:</b>\n\
     1. Browse products with /products\n\
     2. Purchase with /buy &lt;product_id&gt;\n\
     3. Complete payment in Telegram\n\
     4. Receive confirmation\n\n\
     <b>Features:</b>\n\
     • Secure payment processing\n\
     • Multiple payment providers\n\
     • Shipping options (for physical items)\n\
     • Order tracking\n\
     • Automatic fulfillment"
  in

  let* _msg = answer ctx help_text in
  Flo.success "[Handler] ✅ Help sent";
  Ok ()

(** {1 Event Handlers} *)

let handle_shipping_query ctx (query : Telegram_generated.Gen_types.ShippingQuery.t) =
  Flo.debugf "[Handler] Shipping query received: query_id=%s" query.id;
  let open Bot.Ctx in

  let client = client ctx in

  let address = query.shipping_address in

  match ShippingHelper.get_available_options address with
  | Error err ->
      Flo.errorf "[Handler] ❌ Failed to get shipping options: %s" (Format.asprintf "%a" Error.pp err);

      let* _result = Telegram_generated.Gen_methods.answer_shipping_query client
        ~shipping_query_id:query.id
        ~ok:false
        ~error_message:"Unable to determine shipping options"
        ()
      in
      Ok ()

  | Ok options ->
      Flo.successf "[Handler] ✅ Answering shipping query with %d options" (List.length options);

      let* _result = Telegram_generated.Gen_methods.answer_shipping_query client
        ~shipping_query_id:query.id
        ~ok:true
        ~shipping_options:options
        ()
      in

      Flo.success "[Handler] ✅ Shipping query answered";
      Ok ()

let handle_pre_checkout_query ctx (pcq : Telegram_generated.Gen_types.PreCheckoutQuery.t) =
  Flo.debugf "[Handler] Pre-checkout query received: query_id=%s, payload=%s"
    pcq.id pcq.invoice_payload;

  let open Bot.Ctx in

  let client = client ctx in

  (* Validate order exists *)
  match OrderManager.find pcq.invoice_payload with
  | None ->
      Flo.errorf "[Handler] ❌ Invalid order payload: %s" pcq.invoice_payload;

      let* _result = Telegram_generated.Gen_methods.answer_pre_checkout_query client
        ~pre_checkout_query_id:pcq.id
        ~ok:false
        ~error_message:"Invalid order. Please try again."
        ()
      in
      Ok ()

  | Some order ->
      (* Validate amount matches *)
      let expected_amount = order.total_amount in
      let provided_amount = pcq.total_amount in

      if expected_amount <> provided_amount then begin
        Flo.errorf "[Handler] ❌ Amount mismatch: expected=%Ld, provided=%Ld"
          expected_amount provided_amount;

        let* _result = Telegram_generated.Gen_methods.answer_pre_checkout_query client
          ~pre_checkout_query_id:pcq.id
          ~ok:false
          ~error_message:"Price mismatch. Please try again."
          ()
        in
        Ok ()
      end else begin
        Flo.success "[Handler] ✅ Pre-checkout validation passed";

        let* _result = Telegram_generated.Gen_methods.answer_pre_checkout_query client
          ~pre_checkout_query_id:pcq.id
          ~ok:true
          ()
        in

        Flo.success "[Handler] ✅ Pre-checkout query approved";
        Ok ()
      end

let handle_successful_payment ctx (sp : Telegram_generated.Gen_types.SuccessfulPayment.t) =
  Flo.successf "[Handler] Successful payment received: order=%s, amount=%Ld %s"
    sp.invoice_payload sp.total_amount sp.currency;

  let open Bot.Ctx in

  let order_id = sp.invoice_payload in
  let telegram_charge_id = sp.telegram_payment_charge_id in
  let provider_charge_id = sp.provider_payment_charge_id in

  Flo.debugf "[Handler] Charge IDs: telegram=%s, provider=%s"
    telegram_charge_id provider_charge_id;

  (* Mark order as paid *)
  let* order = OrderManager.mark_paid
    ~order_id
    ~telegram_charge_id
    ~provider_charge_id
  in

  (* Get product info *)
  let product_name = match ProductCatalog.find order.product_id with
    | Some p -> p.name
    | None -> "Unknown Product"
  in

  (* Send confirmation *)
  let confirmation_text = Printf.sprintf
    "✅ <b>Payment Successful!</b>\n\n\
     Thank you for your purchase.\n\n\
     <b>Order Details:</b>\n\
     Product: %s\n\
     Amount: $%.2f %s\n\
     Order ID: %s\n\n\
     Your order will be processed shortly."
    product_name
    (Int64.to_float sp.total_amount /. 100.0)
    sp.currency
    (String.sub order_id 0 (min 12 (String.length order_id)))
  in

  let* _msg = answer ctx confirmation_text in

  (* Mark as fulfilled (in real app, this would happen after actual fulfillment) *)
  let* () = OrderManager.update_status order_id Fulfilled in

  Flo.success "[Handler] ✅ Payment processed and order fulfilled";
  Ok ()

let handle_payment_events ctx update =
  Flo.debug "[Handler] Checking for payment-related events";

  (* Check for shipping query *)
  match update.Telegram_generated.Gen_types.Update.shipping_query with
  | Some query ->
      Flo.debug "[Handler] Processing shipping query";
      handle_shipping_query ctx query
  | None ->
      (* Check for pre-checkout query *)
      (match update.pre_checkout_query with
       | Some pcq ->
           Flo.debug "[Handler] Processing pre-checkout query";
           handle_pre_checkout_query ctx pcq
       | None ->
           (* Check for successful payment *)
           (match update.message with
            | Some msg ->
                (match msg.successful_payment with
                 | Some sp ->
                     Flo.success "[Handler] Processing successful payment";
                     handle_successful_payment ctx sp
                 | None -> Ok ()
                )
            | None -> Ok ()
           )
      )

(** {1 Build Routes} *)

let build_routes bot =
  Flo.debug "[Builder] Registering routes...";

  let bot = bot |> Bot.command "start" handle_start in
  Flo.success "[Builder] ✅ Registered /start";

  let bot = bot |> Bot.command "products" handle_products in
  Flo.success "[Builder] ✅ Registered /products";

  let bot = bot |> Bot.command "buy" handle_buy in
  Flo.success "[Builder] ✅ Registered /buy";

  let bot = bot |> Bot.command "link" handle_link in
  Flo.success "[Builder] ✅ Registered /link";

  let bot = bot |> Bot.command "orders" handle_orders in
  Flo.success "[Builder] ✅ Registered /orders";

  let bot = bot |> Bot.command "help" handle_help in
  Flo.success "[Builder] ✅ Registered /help";

  (* Register payment event handler *)
  let bot = bot |> Bot.on Bot.Event.any handle_payment_events in
  Flo.success "[Builder] ✅ Registered payment event handler";

  Flo.debug "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Payment Bot                                  ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "";

  (* Phase 1: Initialize *)
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 1: Initialize                          ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Flo.info "[Init] ✅ Token loaded from environment";
        t
    | None ->
        Flo.info "[Init] ❌ TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  let telegram_client = Telegram.Client.create ~env ~token () in
  Flo.info "[Init] Client created successfully";

  (* Check for Stars support *)
  (match Sys.getenv_opt "ENABLE_STARS" with
   | Some "true" | Some "1" ->
       PaymentProvider.enable_stars ()
   | _ ->
       Flo.info "[Init] Stars payments disabled (set ENABLE_STARS=true to enable)"
  );

  (* Phase 2: Build bot *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 2: Build Bot                           ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Bot.make ~env ~client:telegram_client in
  let bot = build_routes bot in

  Flo.info "[Init] Bot created successfully";

  (* Phase 3: Start polling *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 3: Start Polling                       ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  Flo.info "[Polling] Starting long polling with payment updates...";
  Flo.info "[Polling] Bot is ready to receive updates";
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Waiting for messages...";
  Flo.debug "";
  Flo.info "Features:";
  Flo.debug "  - Product catalog with multiple items";
  Flo.debug "  - Invoice creation and sending";
  Flo.debug "  - Shareable payment links";
  Flo.debug "  - Shipping query handling";
  Flo.debug "  - Pre-checkout validation";
  Flo.success "  - Successful payment processing";
  Flo.debug "  - Order tracking and fulfillment";
  Flo.debug "  - Multiple payment providers";
  Flo.debug "  - Result-based error handling";
  Flo.debug "";
  Flo.debug "Environment Variables:";
  Flo.debug "  - TELEGRAM_BOT_TOKEN (required)";
  Flo.debug "  - PAYMENT_PROVIDER_TOKEN (optional, uses test token if not set)";
  Flo.debug "  - ENABLE_STARS (optional, set to 'true' to enable Stars)";
  Flo.debug "";

  Bot.run bot
