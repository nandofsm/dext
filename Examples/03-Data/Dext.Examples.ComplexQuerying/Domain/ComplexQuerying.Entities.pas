unit ComplexQuerying.Entities;

interface

uses
  Dext.Entity,
  Dext.Core.SmartTypes;

type
  /// <summary>
  ///   Customer entity with metadata
  /// </summary>
  [Table('customers')]
  TCustomer = class
  private
    FId: Int64;
    FName: StringType;
    FEmail: StringType;
    FTags: StringType; // JSON array as string
    FMetadata: StringType; // JSON object as string
    FCreatedAt: DateTimeType;
    FTotalSpent: CurrencyType;
  public
    [PK, AutoInc]
    property Id: Int64 read FId write FId;
    
    [Required, MaxLength(100)]
    property Name: StringType read FName write FName;
    
    [MaxLength(150)]
    property Email: StringType read FEmail write FEmail;
    
    /// JSON array of tags (stored as string)
    property Tags: StringType read FTags write FTags;

    /// JSON object with custom metadata (stored as string)
    property Metadata: StringType read FMetadata write FMetadata;

    property CreatedAt: DateTimeType read FCreatedAt write FCreatedAt;

    [Precision(18, 2)]
    property TotalSpent: CurrencyType read FTotalSpent write FTotalSpent;
  end;

  /// <summary>
  ///   Order entity for complex query demonstrations
  /// </summary>
  [Table('orders')]
  TOrder = class
  private
    FId: Int64;
    FCustomerId: Int64;
    FOrderNumber: StringType;
    FStatus: StringType;
    FTotalAmount: CurrencyType;
    FItems: StringType; // JSON array of order items
    FShippingAddress: StringType; // JSON object
    FCreatedAt: DateTimeType;
    FUpdatedAt: DateTimeType;
  public
    [PK, AutoInc]
    property Id: Int64 read FId write FId;

    property CustomerId: Int64 read FCustomerId write FCustomerId;
    
    [MaxLength(50)]
    property OrderNumber: StringType read FOrderNumber write FOrderNumber;
    
    [MaxLength(20)]
    property Status: StringType read FStatus write FStatus;
    
    [Precision(18, 2)]
    property TotalAmount: CurrencyType read FTotalAmount write FTotalAmount;

    /// JSON array: [{"productId": 1, "qty": 2, "price": 29.99}, ...]
    property Items: StringType read FItems write FItems;

    /// JSON object: {"street": "...", "city": "...", "zip": "..."}
    property ShippingAddress: StringType read FShippingAddress write FShippingAddress;

    property CreatedAt: DateTimeType read FCreatedAt write FCreatedAt;

    property UpdatedAt: DateTimeType read FUpdatedAt write FUpdatedAt;
  end;

  /// <summary>
  ///   Product entity
  /// </summary>
  [Table('products')]
  TProduct = class
  private
    FId: Int64;
    FName: StringType;
    FCategory: StringType;
    FPrice: CurrencyType;
    FStock: IntType;
    FAttributes: StringType; // JSON object
  public
    [PK, AutoInc]
    property Id: Int64 read FId write FId;
    
    [Required, MaxLength(100)]
    property Name: StringType read FName write FName;
    
    [MaxLength(50)]
    property Category: StringType read FCategory write FCategory;
    
    [Precision(18, 2)]
    property Price: CurrencyType read FPrice write FPrice;
    
    property Stock: IntType read FStock write FStock;
    
    /// JSON object with product attributes
    property Attributes: StringType read FAttributes write FAttributes;
  end;

  // ============================================================
  // DTOs for Reports and Search
  // ============================================================

  TSalesReportItem = record
    Status: string;
    OrderCount: Integer;
    TotalAmount: Currency;
  end;

  TTopCustomerItem = record
    CustomerId: Int64;
    CustomerName: string;
    OrderCount: Integer;
    TotalSpent: Currency;
  end;

  TOrderFilter = record
    Status: string;
    MinAmount: Currency;
    MaxAmount: Currency;
    CustomerName: string;
    FromDate: TDateTime;
    ToDate: TDateTime;
  end;

implementation

end.
