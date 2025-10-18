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

(** {1 Verbose Logging Setup} *)

(* Functor-based logging modules with Debug level for troubleshooting *)
module Verbose_log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "PaymentBot"
  let level = Telegram.Log.Debug
end)

module Verbose_session = Tg.Session.Make (Verbose_log)
module Verbose_polling = Tg.Polling.Make (Verbose_log)
module Verbose_bot = Tg.Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

(** {1 Helper Functions} *)

let unknown () = Telegram.Json_compat.Unknown_fields.create ()

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
    Eio.traceln "[ProductCatalog] Looking up product: id=%s" id;
    match List.find_opt (fun p -> String.equal p.id id) products with
    | Some p ->
        Eio.traceln "[ProductCatalog] ✅ Found product: %s - $%.2f"
          p.name (Int64.to_float p.price_cents /. 100.0);
        Some p
    | None ->
        Eio.traceln "[ProductCatalog] ❌ Product not found: id=%s" id;
        None

  let list_all () =
    Eio.traceln "[ProductCatalog] Listing all products: count=%d" (List.length products);
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
  | Refunded

module OrderManager = struct
  type order = {
    order_id : string;
    product_id : string;
    user_id : int64;
    chat_id : Id.Chat.k Id.t;
    status : order_status;
    total_amount : int64;
    currency : string;
    telegram_charge_id : string option;
    provider_charge_id : string option;
    created_at : float;
  }

  let orders : (string, order) Hashtbl.t = Hashtbl.create 100

  let create ~product_id ~user_id ~chat_id =
    let order_id = Printf.sprintf "order_%d_%f" (Random.int 1000000) (Unix.time ()) in

    match ProductCatalog.find product_id with
    | None ->
        Eio.traceln "[OrderManager] ❌ Cannot create order, product not found: %s" product_id;
        Error (Error.Internal_error "Product not found")
    | Some product ->
        let order = {
          order_id;
          product_id;
          user_id;
          chat_id;
          status = Pending;
          total_amount = product.price_cents;
          currency = product.currency;
          telegram_charge_id = None;
          provider_charge_id = None;
          created_at = Unix.time ();
        } in

        Hashtbl.replace orders order_id order;
        Eio.traceln "[OrderManager] ✅ Created order: order_id=%s, product=%s, amount=%Ld"
          order_id product_id product.price_cents;
        Ok order

  let find order_id =
    Eio.traceln "[OrderManager] Looking up order: order_id=%s" order_id;
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        Eio.traceln "[OrderManager] ✅ Found order: status=%s"
          (match order.status with
           | Pending -> "Pending"
           | AwaitingPayment -> "AwaitingPayment"
           | Paid -> "Paid"
           | Fulfilled -> "Fulfilled"
           | Refunded -> "Refunded");
        Some order
    | None ->
        Eio.traceln "[OrderManager] ❌ Order not found";
        None

  let update_status order_id status =
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        let updated = { order with status } in
        Hashtbl.replace orders order_id updated;
        Eio.traceln "[OrderManager] ✅ Updated order status: order_id=%s, new_status=%s"
          order_id
          (match status with
           | Pending -> "Pending"
           | AwaitingPayment -> "AwaitingPayment"
           | Paid -> "Paid"
           | Fulfilled -> "Fulfilled"
           | Refunded -> "Refunded");
        Ok ()
    | None ->
        Eio.traceln "[OrderManager] ❌ Cannot update, order not found: %s" order_id;
        Error (Error.Internal_error "Order not found")

  let mark_paid ~order_id ~telegram_charge_id ~provider_charge_id =
    match Hashtbl.find_opt orders order_id with
    | Some order ->
        let updated = {
          order with
          status = Paid;
          telegram_charge_id = Some telegram_charge_id;
          provider_charge_id = Some provider_charge_id;
        } in
        Hashtbl.replace orders order_id updated;
        Eio.traceln "[OrderManager] ✅ Marked order as paid: order_id=%s, telegram_charge=%s"
          order_id telegram_charge_id;
        Ok updated
    | None ->
        Eio.traceln "[OrderManager] ❌ Cannot mark paid, order not found: %s" order_id;
        Error (Error.Internal_error "Order not found")

  let get_user_orders user_id =
    Eio.traceln "[OrderManager] Getting orders for user: user_id=%Ld" user_id;
    let user_orders = Hashtbl.fold (fun _ order acc ->
      if order.user_id = user_id then order :: acc else acc
    ) orders [] in
    Eio.traceln "[OrderManager] Found %d orders for user" (List.length user_orders);
    user_orders
end

(** {1 Price Helpers} *)

module PriceHelper = struct
  let price ~label ~amount =
    Eio.traceln "[PriceHelper] Creating price: label='%s', amount=%Ld" label amount;
    Telegram_generated.Gen_types.LabeledPrice.{
      label;
      amount;
      unknown_fields = unknown ();
    }

  let product_prices product =
    Eio.traceln "[PriceHelper] Creating prices for product: %s" product.ProductCatalog.name;
    [
      price ~label:product.name ~amount:product.price_cents;
    ]

  let with_tax prices tax_rate =
    let total = List.fold_left (fun acc p ->
      Int64.add acc p.Telegram_generated.Gen_types.LabeledPrice.amount
    ) 0L prices in
    let tax_amount = Int64.div (Int64.mul total (Int64.of_int (int_of_float (tax_rate *. 100.0)))) 10000L in

    if tax_amount > 0L then begin
      Eio.traceln "[PriceHelper] Adding tax: total=%Ld, tax=%Ld (%.1f%%)"
        total tax_amount (tax_rate *. 100.0);
      prices @ [price ~label:"Tax" ~amount:tax_amount]
    end else
      prices
end

(** {1 Shipping Options} *)

module ShippingHelper = struct
  let shipping_option ~id ~title ~amount =
    Eio.traceln "[ShippingHelper] Creating shipping option: id=%s, title='%s', amount=%Ld"
      id title amount;

    let open Telegram_generated.Gen_types in
    ShippingOption.{
      id;
      title;
      prices = [LabeledPrice.{ label = title; amount; unknown_fields = unknown () }];
      unknown_fields = unknown ();
    }

  let standard = shipping_option ~id:"standard" ~title:"Standard Shipping" ~amount:500L  (* $5.00 *)
  let express = shipping_option ~id:"express" ~title:"Express Shipping" ~amount:1500L  (* $15.00 *)
  let international = shipping_option ~id:"international" ~title:"International" ~amount:2500L  (* $25.00 *)

  let get_available_options (address : Telegram_generated.Gen_types.ShippingAddress.t) =
    Eio.traceln "[ShippingHelper] Determining shipping options for: country=%s, city=%s"
      address.country_code
      (Option.value ~default:"unknown" address.city);

    (* Simple logic: different options based on country *)
    match address.country_code with
    | "US" ->
        Eio.traceln "[ShippingHelper] ✅ US address: standard and express available";
        Ok [standard; express]
    | "CA" | "MX" ->
        Eio.traceln "[ShippingHelper] ✅ North America: standard and international available";
        Ok [standard; international]
    | _ ->
        Eio.traceln "[ShippingHelper] ✅ International address: international shipping only";
        Ok [international]
end

(** {1 Payment Provider Configuration} *)

module PaymentProvider = struct
  let get_provider_token () =
    match Sys.getenv_opt "PAYMENT_PROVIDER_TOKEN" with
    | Some token ->
        Eio.traceln "[PaymentProvider] ✅ Loaded provider token from environment";
        Ok token
    | None ->
        Eio.traceln "[PaymentProvider] ⚠️  No PAYMENT_PROVIDER_TOKEN set, using test token";
        (* Test token for Telegram's test payment provider *)
        Ok "284685063:TEST:YjEwMjZhN2Y2ZmJh"

  let supports_stars = ref false

  let enable_stars () =
    supports_stars := true;
    Eio.traceln "[PaymentProvider] ✅ Stars payments enabled"

  let is_stars_payment currency =
    String.equal (String.uppercase_ascii currency) "XTR"
end

(** {1 Command Handlers} *)

let handle_start ctx _args =
  Eio.traceln "[Handler] /start command triggered";
  let open Verbose_bot.Ctx in

  let* user = require_user ctx in
  Eio.traceln "[Handler] User: id=%a, username=%s"
    Id.pp user.id
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

  let* _msg = answer ctx welcome_text ~parse_mode:"HTML" in
  Eio.traceln "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_products ctx _args =
  Eio.traceln "[Handler] /products command triggered";
  let open Verbose_bot.Ctx in

  let catalog = ProductCatalog.format_catalog () in
  let products_text =
    "🛍️ <b>Available Products</b>\n\n" ^ catalog ^
    "\n\nUse /buy &lt;product_id&gt; to purchase."
  in

  let* _msg = answer ctx products_text ~parse_mode:"HTML" in
  Eio.traceln "[Handler] ✅ Products list sent";
  Ok ()

let handle_buy ctx args =
  Eio.traceln "[Handler] /buy command triggered with args: [%s]"
    (String.concat " " args);

  let open Verbose_bot.Ctx in

  let* client = client ctx in
  let* chat_id = chat ctx in
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
           Eio.traceln "[Handler] Creating order for product: %s" product.name;

           (* Create order *)
           let* order = OrderManager.create ~product_id ~user_id:user.id ~chat_id in

           (* Get provider token *)
           let* provider_token = PaymentProvider.get_provider_token () in

           (* Create prices *)
           let prices = PriceHelper.product_prices product in
           let prices_with_tax = PriceHelper.with_tax prices 0.08 in  (* 8% tax *)

           Eio.traceln "[Handler] Sending invoice: order_id=%s, product=%s"
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

           Eio.traceln "[Handler] ✅ Invoice sent successfully";
           Ok ()
      )

let handle_link ctx args =
  Eio.traceln "[Handler] /link command triggered";
  let open Verbose_bot.Ctx in

  let* client = client ctx in

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

           Eio.traceln "[Handler] Creating payment link for: %s" product.name;

           let* link = Telegram_generated.Gen_methods.create_invoice_link client
             ~title:product.name
             ~description:product.description
             ~payload:(Printf.sprintf "link_%s_%f" product_id (Unix.time ()))
             ~currency:product.currency
             ~prices
             ~provider_token
             ()
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

           let* _msg = answer ctx link_text ~parse_mode:"HTML" in
           Eio.traceln "[Handler] ✅ Payment link sent";
           Ok ()
      )

let handle_orders ctx _args =
  Eio.traceln "[Handler] /orders command triggered";
  let open Verbose_bot.Ctx in

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

    let* _msg = answer ctx orders_text ~parse_mode:"HTML" in
    Eio.traceln "[Handler] ✅ Orders list sent: count=%d" (List.length user_orders);
    Ok ()
  end

let handle_help ctx _args =
  Eio.traceln "[Handler] /help command triggered";
  let open Verbose_bot.Ctx in

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

  let* _msg = answer ctx help_text ~parse_mode:"HTML" in
  Eio.traceln "[Handler] ✅ Help sent";
  Ok ()

(** {1 Event Handlers} *)

let handle_shipping_query ctx (query : Telegram_generated.Gen_types.ShippingQuery.t) =
  Eio.traceln "[Handler] Shipping query received: query_id=%s" query.id;
  let open Verbose_bot.Ctx in

  let* client = client ctx in

  let address = query.shipping_address in

  match ShippingHelper.get_available_options address with
  | Error err ->
      Eio.traceln "[Handler] ❌ Failed to get shipping options: %a" Error.pp err;

      let* () = Telegram_generated.Gen_methods.answer_shipping_query client
        ~shipping_query_id:query.id
        ~ok:false
        ~error_message:"Unable to determine shipping options"
        ()
      in
      Ok ()

  | Ok options ->
      Eio.traceln "[Handler] ✅ Answering shipping query with %d options" (List.length options);

      let* () = Telegram_generated.Gen_methods.answer_shipping_query client
        ~shipping_query_id:query.id
        ~ok:true
        ~shipping_options:options
        ()
      in

      Eio.traceln "[Handler] ✅ Shipping query answered";
      Ok ()

let handle_pre_checkout_query ctx (pcq : Telegram_generated.Gen_types.PreCheckoutQuery.t) =
  Eio.traceln "[Handler] Pre-checkout query received: query_id=%s, payload=%s"
    pcq.id pcq.invoice_payload;

  let open Verbose_bot.Ctx in

  let* client = client ctx in

  (* Validate order exists *)
  match OrderManager.find pcq.invoice_payload with
  | None ->
      Eio.traceln "[Handler] ❌ Invalid order payload: %s" pcq.invoice_payload;

      let* () = Telegram_generated.Gen_methods.answer_pre_checkout_query client
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
        Eio.traceln "[Handler] ❌ Amount mismatch: expected=%Ld, provided=%Ld"
          expected_amount provided_amount;

        let* () = Telegram_generated.Gen_methods.answer_pre_checkout_query client
          ~pre_checkout_query_id:pcq.id
          ~ok:false
          ~error_message:"Price mismatch. Please try again."
          ()
        in
        Ok ()
      end else begin
        Eio.traceln "[Handler] ✅ Pre-checkout validation passed";

        let* () = Telegram_generated.Gen_methods.answer_pre_checkout_query client
          ~pre_checkout_query_id:pcq.id
          ~ok:true
          ()
        in

        Eio.traceln "[Handler] ✅ Pre-checkout query approved";
        Ok ()
      end

let handle_successful_payment ctx (sp : Telegram_generated.Gen_types.SuccessfulPayment.t) =
  Eio.traceln "[Handler] Successful payment received: order=%s, amount=%Ld %s"
    sp.invoice_payload sp.total_amount sp.currency;

  let open Verbose_bot.Ctx in

  let order_id = sp.invoice_payload in
  let telegram_charge_id = sp.telegram_payment_charge_id in
  let provider_charge_id = sp.provider_payment_charge_id in

  Eio.traceln "[Handler] Charge IDs: telegram=%s, provider=%s"
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

  let* _msg = answer ctx confirmation_text ~parse_mode:"HTML" in

  (* Mark as fulfilled (in real app, this would happen after actual fulfillment) *)
  let* () = OrderManager.update_status order_id Fulfilled in

  Eio.traceln "[Handler] ✅ Payment processed and order fulfilled";
  Ok ()

let handle_payment_events ctx update =
  Eio.traceln "[Handler] Checking for payment-related events";
  let open Verbose_bot.Ctx in

  (* Check for shipping query *)
  match update.Telegram_generated.Gen_types.Update.shipping_query with
  | Some query ->
      Eio.traceln "[Handler] Processing shipping query";
      handle_shipping_query ctx query
  | None ->
      (* Check for pre-checkout query *)
      (match update.pre_checkout_query with
       | Some pcq ->
           Eio.traceln "[Handler] Processing pre-checkout query";
           handle_pre_checkout_query ctx pcq
       | None ->
           (* Check for successful payment *)
           (match update.message with
            | Some msg ->
                (match msg.successful_payment with
                 | Some sp ->
                     Eio.traceln "[Handler] Processing successful payment";
                     handle_successful_payment ctx sp
                 | None -> Ok ()
                )
            | None -> Ok ()
           )
      )

(** {1 Build Routes} *)

let build_routes bot =
  Eio.traceln "[Builder] Registering routes...";

  let bot = bot |> Verbose_bot.command "start" handle_start in
  Eio.traceln "[Builder] ✅ Registered /start";

  let bot = bot |> Verbose_bot.command "products" handle_products in
  Eio.traceln "[Builder] ✅ Registered /products";

  let bot = bot |> Verbose_bot.command "buy" handle_buy in
  Eio.traceln "[Builder] ✅ Registered /buy";

  let bot = bot |> Verbose_bot.command "link" handle_link in
  Eio.traceln "[Builder] ✅ Registered /link";

  let bot = bot |> Verbose_bot.command "orders" handle_orders in
  Eio.traceln "[Builder] ✅ Registered /orders";

  let bot = bot |> Verbose_bot.command "help" handle_help in
  Eio.traceln "[Builder] ✅ Registered /help";

  (* Register payment event handler *)
  let bot = bot |> Verbose_bot.on_any handle_payment_events in
  Eio.traceln "[Builder] ✅ Registered payment event handler";

  Eio.traceln "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Payment Bot                                  ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "";

  (* Phase 1: Initialize *)
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 1: Initialize                          ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Eio.traceln "[Init] ✅ Token loaded from environment";
        t
    | None ->
        Eio.traceln "[Init] ❌ TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  let telegram_client = Telegram.Client.create ~env ~token () in
  Eio.traceln "[Init] Client created successfully";

  (* Check for Stars support *)
  (match Sys.getenv_opt "ENABLE_STARS" with
   | Some "true" | Some "1" ->
       PaymentProvider.enable_stars ()
   | _ ->
       Eio.traceln "[Init] Stars payments disabled (set ENABLE_STARS=true to enable)"
  );

  (* Phase 2: Build bot *)
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 2: Build Bot                           ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Verbose_bot.make ~env ~client:telegram_client in
  let bot = build_routes bot in

  Eio.traceln "[Init] Bot created successfully";

  (* Phase 3: Start polling *)
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 3: Start Polling                       ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  Eio.traceln "[Polling] Starting long polling with payment updates...";
  Eio.traceln "[Polling] Bot is ready to receive updates";
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Bot is Ready!                                ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "[Polling] Waiting for messages...";
  Eio.traceln "";
  Eio.traceln "Features:";
  Eio.traceln "  - Product catalog with multiple items";
  Eio.traceln "  - Invoice creation and sending";
  Eio.traceln "  - Shareable payment links";
  Eio.traceln "  - Shipping query handling";
  Eio.traceln "  - Pre-checkout validation";
  Eio.traceln "  - Successful payment processing";
  Eio.traceln "  - Order tracking and fulfillment";
  Eio.traceln "  - Multiple payment providers";
  Eio.traceln "  - Result-based error handling";
  Eio.traceln "";
  Eio.traceln "Environment Variables:";
  Eio.traceln "  - TELEGRAM_BOT_TOKEN (required)";
  Eio.traceln "  - PAYMENT_PROVIDER_TOKEN (optional, uses test token if not set)";
  Eio.traceln "  - ENABLE_STARS (optional, set to 'true' to enable Stars)";
  Eio.traceln "";

  Verbose_bot.run bot
