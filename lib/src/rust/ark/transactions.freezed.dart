// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transactions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transaction {

 PlatformInt64 get sats;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.sats, sats) || other.sats == sats));
}


@override
int get hashCode => Object.hash(runtimeType,sats);

@override
String toString() {
  return 'Transaction(sats: $sats)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 int sats
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sats = null,}) {
  return _then(_self.copyWith(
sats: null == sats ? _self.sats : sats // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Transaction_Boarding value)?  boarding,TResult Function( Transaction_Commitment value)?  commitment,TResult Function( Transaction_Redeem value)?  redeem,TResult Function( Transaction_Offboard value)?  offboard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Transaction_Boarding() when boarding != null:
return boarding(_that);case Transaction_Commitment() when commitment != null:
return commitment(_that);case Transaction_Redeem() when redeem != null:
return redeem(_that);case Transaction_Offboard() when offboard != null:
return offboard(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Transaction_Boarding value)  boarding,required TResult Function( Transaction_Commitment value)  commitment,required TResult Function( Transaction_Redeem value)  redeem,required TResult Function( Transaction_Offboard value)  offboard,}){
final _that = this;
switch (_that) {
case Transaction_Boarding():
return boarding(_that);case Transaction_Commitment():
return commitment(_that);case Transaction_Redeem():
return redeem(_that);case Transaction_Offboard():
return offboard(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Transaction_Boarding value)?  boarding,TResult? Function( Transaction_Commitment value)?  commitment,TResult? Function( Transaction_Redeem value)?  redeem,TResult? Function( Transaction_Offboard value)?  offboard,}){
final _that = this;
switch (_that) {
case Transaction_Boarding() when boarding != null:
return boarding(_that);case Transaction_Commitment() when commitment != null:
return commitment(_that);case Transaction_Redeem() when redeem != null:
return redeem(_that);case Transaction_Offboard() when offboard != null:
return offboard(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String txid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)?  boarding,TResult Function( String txid,  PlatformInt64 sats,  PlatformInt64 createdAt)?  commitment,TResult Function( String txid,  PlatformInt64 sats,  bool isSettled,  PlatformInt64 createdAt)?  redeem,TResult Function( String commitmentTxid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)?  offboard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Transaction_Boarding() when boarding != null:
return boarding(_that.txid,_that.sats,_that.confirmedAt);case Transaction_Commitment() when commitment != null:
return commitment(_that.txid,_that.sats,_that.createdAt);case Transaction_Redeem() when redeem != null:
return redeem(_that.txid,_that.sats,_that.isSettled,_that.createdAt);case Transaction_Offboard() when offboard != null:
return offboard(_that.commitmentTxid,_that.sats,_that.confirmedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String txid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)  boarding,required TResult Function( String txid,  PlatformInt64 sats,  PlatformInt64 createdAt)  commitment,required TResult Function( String txid,  PlatformInt64 sats,  bool isSettled,  PlatformInt64 createdAt)  redeem,required TResult Function( String commitmentTxid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)  offboard,}) {final _that = this;
switch (_that) {
case Transaction_Boarding():
return boarding(_that.txid,_that.sats,_that.confirmedAt);case Transaction_Commitment():
return commitment(_that.txid,_that.sats,_that.createdAt);case Transaction_Redeem():
return redeem(_that.txid,_that.sats,_that.isSettled,_that.createdAt);case Transaction_Offboard():
return offboard(_that.commitmentTxid,_that.sats,_that.confirmedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String txid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)?  boarding,TResult? Function( String txid,  PlatformInt64 sats,  PlatformInt64 createdAt)?  commitment,TResult? Function( String txid,  PlatformInt64 sats,  bool isSettled,  PlatformInt64 createdAt)?  redeem,TResult? Function( String commitmentTxid,  PlatformInt64 sats,  PlatformInt64? confirmedAt)?  offboard,}) {final _that = this;
switch (_that) {
case Transaction_Boarding() when boarding != null:
return boarding(_that.txid,_that.sats,_that.confirmedAt);case Transaction_Commitment() when commitment != null:
return commitment(_that.txid,_that.sats,_that.createdAt);case Transaction_Redeem() when redeem != null:
return redeem(_that.txid,_that.sats,_that.isSettled,_that.createdAt);case Transaction_Offboard() when offboard != null:
return offboard(_that.commitmentTxid,_that.sats,_that.confirmedAt);case _:
  return null;

}
}

}

/// @nodoc


class Transaction_Boarding extends Transaction {
  const Transaction_Boarding({required this.txid, required this.sats, this.confirmedAt}): super._();
  

 final  String txid;
@override final  PlatformInt64 sats;
 final  PlatformInt64? confirmedAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Transaction_BoardingCopyWith<Transaction_Boarding> get copyWith => _$Transaction_BoardingCopyWithImpl<Transaction_Boarding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction_Boarding&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.sats, sats) || other.sats == sats)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}


@override
int get hashCode => Object.hash(runtimeType,txid,sats,confirmedAt);

@override
String toString() {
  return 'Transaction.boarding(txid: $txid, sats: $sats, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class $Transaction_BoardingCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory $Transaction_BoardingCopyWith(Transaction_Boarding value, $Res Function(Transaction_Boarding) _then) = _$Transaction_BoardingCopyWithImpl;
@override @useResult
$Res call({
 String txid, PlatformInt64 sats, PlatformInt64? confirmedAt
});




}
/// @nodoc
class _$Transaction_BoardingCopyWithImpl<$Res>
    implements $Transaction_BoardingCopyWith<$Res> {
  _$Transaction_BoardingCopyWithImpl(this._self, this._then);

  final Transaction_Boarding _self;
  final $Res Function(Transaction_Boarding) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? sats = null,Object? confirmedAt = freezed,}) {
  return _then(Transaction_Boarding(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,sats: null == sats ? _self.sats : sats // ignore: cast_nullable_to_non_nullable
as PlatformInt64,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64?,
  ));
}


}

/// @nodoc


class Transaction_Commitment extends Transaction {
  const Transaction_Commitment({required this.txid, required this.sats, required this.createdAt}): super._();
  

 final  String txid;
@override final  PlatformInt64 sats;
 final  PlatformInt64 createdAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Transaction_CommitmentCopyWith<Transaction_Commitment> get copyWith => _$Transaction_CommitmentCopyWithImpl<Transaction_Commitment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction_Commitment&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.sats, sats) || other.sats == sats)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,txid,sats,createdAt);

@override
String toString() {
  return 'Transaction.commitment(txid: $txid, sats: $sats, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $Transaction_CommitmentCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory $Transaction_CommitmentCopyWith(Transaction_Commitment value, $Res Function(Transaction_Commitment) _then) = _$Transaction_CommitmentCopyWithImpl;
@override @useResult
$Res call({
 String txid, PlatformInt64 sats, PlatformInt64 createdAt
});




}
/// @nodoc
class _$Transaction_CommitmentCopyWithImpl<$Res>
    implements $Transaction_CommitmentCopyWith<$Res> {
  _$Transaction_CommitmentCopyWithImpl(this._self, this._then);

  final Transaction_Commitment _self;
  final $Res Function(Transaction_Commitment) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? sats = null,Object? createdAt = null,}) {
  return _then(Transaction_Commitment(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,sats: null == sats ? _self.sats : sats // ignore: cast_nullable_to_non_nullable
as PlatformInt64,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,
  ));
}


}

/// @nodoc


class Transaction_Redeem extends Transaction {
  const Transaction_Redeem({required this.txid, required this.sats, required this.isSettled, required this.createdAt}): super._();
  

 final  String txid;
@override final  PlatformInt64 sats;
 final  bool isSettled;
 final  PlatformInt64 createdAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Transaction_RedeemCopyWith<Transaction_Redeem> get copyWith => _$Transaction_RedeemCopyWithImpl<Transaction_Redeem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction_Redeem&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.sats, sats) || other.sats == sats)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,txid,sats,isSettled,createdAt);

@override
String toString() {
  return 'Transaction.redeem(txid: $txid, sats: $sats, isSettled: $isSettled, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $Transaction_RedeemCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory $Transaction_RedeemCopyWith(Transaction_Redeem value, $Res Function(Transaction_Redeem) _then) = _$Transaction_RedeemCopyWithImpl;
@override @useResult
$Res call({
 String txid, PlatformInt64 sats, bool isSettled, PlatformInt64 createdAt
});




}
/// @nodoc
class _$Transaction_RedeemCopyWithImpl<$Res>
    implements $Transaction_RedeemCopyWith<$Res> {
  _$Transaction_RedeemCopyWithImpl(this._self, this._then);

  final Transaction_Redeem _self;
  final $Res Function(Transaction_Redeem) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? sats = null,Object? isSettled = null,Object? createdAt = null,}) {
  return _then(Transaction_Redeem(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,sats: null == sats ? _self.sats : sats // ignore: cast_nullable_to_non_nullable
as PlatformInt64,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64,
  ));
}


}

/// @nodoc


class Transaction_Offboard extends Transaction {
  const Transaction_Offboard({required this.commitmentTxid, required this.sats, this.confirmedAt}): super._();
  

 final  String commitmentTxid;
@override final  PlatformInt64 sats;
 final  PlatformInt64? confirmedAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Transaction_OffboardCopyWith<Transaction_Offboard> get copyWith => _$Transaction_OffboardCopyWithImpl<Transaction_Offboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction_Offboard&&(identical(other.commitmentTxid, commitmentTxid) || other.commitmentTxid == commitmentTxid)&&(identical(other.sats, sats) || other.sats == sats)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}


@override
int get hashCode => Object.hash(runtimeType,commitmentTxid,sats,confirmedAt);

@override
String toString() {
  return 'Transaction.offboard(commitmentTxid: $commitmentTxid, sats: $sats, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class $Transaction_OffboardCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory $Transaction_OffboardCopyWith(Transaction_Offboard value, $Res Function(Transaction_Offboard) _then) = _$Transaction_OffboardCopyWithImpl;
@override @useResult
$Res call({
 String commitmentTxid, PlatformInt64 sats, PlatformInt64? confirmedAt
});




}
/// @nodoc
class _$Transaction_OffboardCopyWithImpl<$Res>
    implements $Transaction_OffboardCopyWith<$Res> {
  _$Transaction_OffboardCopyWithImpl(this._self, this._then);

  final Transaction_Offboard _self;
  final $Res Function(Transaction_Offboard) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commitmentTxid = null,Object? sats = null,Object? confirmedAt = freezed,}) {
  return _then(Transaction_Offboard(
commitmentTxid: null == commitmentTxid ? _self.commitmentTxid : commitmentTxid // ignore: cast_nullable_to_non_nullable
as String,sats: null == sats ? _self.sats : sats // ignore: cast_nullable_to_non_nullable
as PlatformInt64,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as PlatformInt64?,
  ));
}


}

// dart format on
