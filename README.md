Apple Pay iOS - maxiPago! SDK
========================

Apple Pay SDK maxiPago! - Pagamentos Apple Pay em Apps iOS

## Requisitos

-   [integração maxiPago! completa, para viabilizar estornos, capturas entre outras features]
-   [XCode 9, iPhone 6 ou superior]

## Instalação

Faça o clone deste projeto. 

Efetue a configuração para seu ambiente iOS

## Inicialização

A integração com o Apple Pay requer a troca dois certificados com a maxiPago, além da criação de um Merchant ID no Apple Member Center [https://developer.apple.com]

- Merchant Identity Certificate: Responsável pela autenticação de seu merchant ID nos servidores da Apple

- Payment Provider Certificate: Responsável por auxiliar o processo de descriptrografia dos dados de pagamento tokenizados com o Apple Pay.

- O Apple Pay necessita que sua execução seja feita sob um ambiente HTTPS e que este domínio seja verificado no Apple Member Center.

**NOTE: A maxiPago! disponibiliza um guia de afiliação completo para o Produto Apple Pay que te auxiliará neste processo de certificação e verificação de domínio, para mais informações, contate um de nossos representantes :)**


### Setup

Para dar suporte ao Apple Pay, seu app precisa ter a função ativada nos capabilities do App. 

**"Capabilities > Apple Pay > Assinalar o Merchant ID que deseja utilizar."**
![alt text](http://www.maxipago.com/docs/apple_pay_images_wiki/enable_apple_pay.png)

**NOTE: Sua conta do Apple MemberCenter precisa estar vinculada a seu xCODE para viabilizar a adição de seu merchant ID ao projeto.**


``` obj-c
PKPaymentRequest *request = [PKPaymentRequest new];
request.merchantIdentifier = merchant.your.merchant; // Seu merchant ID cadastrado na Apple
request.supportedNetworks = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]; // Bandeiras cadastradas, no momento, suportamos mastercard e visa.
request.merchantCapabilities = PKMerchantCapability3DS; // maxipago dá suporte apenas a segurança 3DS
request.countryCode = @"US";    // O seu código de país. Em sandbox, utilizar "US", em produção, utilizar o código real de seu país.
request.currencyCode = @"BRL";  // Código da moeda conforme ISO 4217

NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:total];
PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:reference amount:totalAmount];
request.paymentSummaryItems = @[totalItem]; // O paymentSummaryItems é um recurso que pode ser utilizado para descontos, parcelamento e outras considerações sobre seu pagamento. 

```

**NOTE: seguir as recomendações acima é mandatório para o funcionamento de seu App com ApplePay.**


### Fluxo Apple Pay
![alt text](https://www.websequencediagrams.com/cgi-bin/cdraw?lz=dGl0bGUgQXBwbGUgUGF5IEFwcCAtIEZsdXhvCgpBcHBEb0xvZ2lzdGEgLT4gU2Vydmlkb3IADAk6IHNlbGVjaW9uYXJJdGVucwoAEhEgLT4gADwMOiBpdGVuc0RvQ2FycmluaG8AVREAIA5JbmljaWFyIFBhZ2FtZW50AB4SbWF4aVBhZ29HYXRld2F5OgCBSAZQYXltZW50VG9rZW4Kbm90ZSBvdmVyAIExEiwALhIASQghIEFkZGl0aW9uYWwgRGF0YQplbmQgAEcFCgBmDwCBVBJSZXNwb25zZSBGcm9tAIEUEAAtEgCCFRFub3RpZmljYcOnw6NvIGRvIGF1dGggLyBjYXB0dXJlIAoKCg&s=rose)


## Implementação

No item .m "RESTAPIClient.m" : adicionar os parâmetros adicionais da maxiPago! conforme manual de integração.Altere o endpoint da api da maxiPago! no recurso consumidor: 

SANDBOX: https://testapi.maxipago.net/UniversalAPI/rest/EncryptedWallet/order

PRODUÇÃO: https://api.maxipago.net/UniversalAPI/rest/EncryptedWallet/order

 **NOTE: Esta loja exemplo possui alguns logs para auxilia-lo na depuração, retire os logs antes de rodar em produção.**

No item .m "PaymentRequestController.m", método prepareMaxiPagoRequestData, colocar os parâmetos da chamada JSON conforme a sua necessidade de negócio e atentar-se para o transactionType, conforme manual de integração.

Exemplo de preenchimento com recorrência: 

``` obj-c
maxiPagoPaymentRequest =
        @{
          @"wallet": @"applePay",
          @"referenceNumber": @"TEST-APPLE-PAY-RF",
          @"installments": @4,
          @"chargeInterest": @"Y",
          @"walletDetail": @{
                  @"merchantIdentifier": @"merchant.your.merchant.com",
                  @"transactionType": transactionTypeG,
                  @"recurring":@{
                      @"action":@"new",
                      @"startDate":@"2018-10-07",
                      @"period":@"daily",
                      @"frequency":@"1",
                      @"installments":@"12",
                      @"firstAmount":@"100",
                      @"lastAmount":@"1000",
                      @"lastDate":@"2020-10-05",
                      @"failureThreshold":@"1"
                  },
                  @"applePayPayment": @{
                          @"paymentData": @{
                                  @"version": paymentTokenJSON[@"version"],
                                  @"data": paymentTokenJSON[@"data"],
                                  @"signature": paymentTokenJSON[@"signature"],
                                  @"header": @{
                                          @"ephemeralPublicKey": paymentHeader[@"ephemeralPublicKey"],
                                          @"publicKeyHash": paymentHeader[@"publicKeyHash"],
                                          @"transactionId": paymentHeader[@"transactionId"],
                                          }
                                  },
                          @"paymentMethod": @{
                                  @"displayName": payment.token.paymentMethod.displayName,
                                  @"network": payment.token.paymentMethod.network,
                                  @"type": paymentType
                                  },
                          @"transactionIdentifier": payment.token.transactionIdentifier
                          }
                  }
          };

``` 


