// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPokemonByDexNumberQuery: GraphQLQuery {
  public static let operationName: String = "GetPokemonByDexNumber"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPokemonByDexNumber($number: Int!) { getPokemonByDexNumber(number: $number) { __typename abilities { __typename first { __typename name shortDesc desc serebiiPage smogonPage } second { __typename name shortDesc desc serebiiPage smogonPage } hidden { __typename name shortDesc desc serebiiPage smogonPage } } backSprite baseStats { __typename attack defense hp specialattack specialdefense speed } baseStatsTotal catchRate { __typename base percentageWithOrdinaryPokeballAtFullHealth } color eggGroups evYields { __typename attack defense hp specialattack specialdefense speed } evolutionLevel flavorTexts { __typename flavor game } gender { __typename female male } height num preevolutions { __typename species } serebiiPage shinyBackSprite shinySprite smogonPage smogonTier species sprite types { __typename name } weight } }"#
    ))

  public var number: Int

  public init(number: Int) {
    self.number = number
  }

  public var __variables: Variables? { ["number": number] }

  public struct Data: PkmnApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getPokemonByDexNumber", GetPokemonByDexNumber.self, arguments: ["number": .variable("number")]),
    ] }

    /// Gets details on a single Pokémon based on National Pokédex number
    ///
    /// You can provide `takeFlavorTexts` to limit the amount of flavour texts to return, set the offset of where to start with `offsetFlavorTexts`, and reverse the entire array with `reverseFlavorTexts`.
    ///
    /// **Reversal is applied before pagination!**
    public var getPokemonByDexNumber: GetPokemonByDexNumber { __data["getPokemonByDexNumber"] }

    /// GetPokemonByDexNumber
    ///
    /// Parent Type: `Pokemon`
    public struct GetPokemonByDexNumber: PkmnApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Pokemon }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("abilities", Abilities.self),
        .field("backSprite", String.self),
        .field("baseStats", BaseStats.self),
        .field("baseStatsTotal", Int.self),
        .field("catchRate", CatchRate?.self),
        .field("color", String.self),
        .field("eggGroups", [String]?.self),
        .field("evYields", EvYields.self),
        .field("evolutionLevel", String?.self),
        .field("flavorTexts", [FlavorText].self),
        .field("gender", Gender.self),
        .field("height", Double.self),
        .field("num", Int.self),
        .field("preevolutions", [Preevolution]?.self),
        .field("serebiiPage", String.self),
        .field("shinyBackSprite", String.self),
        .field("shinySprite", String.self),
        .field("smogonPage", String.self),
        .field("smogonTier", String.self),
        .field("species", String.self),
        .field("sprite", String.self),
        .field("types", [Type_SelectionSet].self),
        .field("weight", Double.self),
      ] }

      /// The abilities for a Pokémon
      public var abilities: Abilities { __data["abilities"] }
      /// The back sprite for a Pokémon. For most Pokémon this will be the animated gif, with some exceptions that were older-gen exclusive
      public var backSprite: String { __data["backSprite"] }
      /// Base stats for a Pokémon
      public var baseStats: BaseStats { __data["baseStats"] }
      /// The total of all base stats for a Pokémon
      public var baseStatsTotal: Int { __data["baseStatsTotal"] }
      /// The catch rate data for a Pokémon
      public var catchRate: CatchRate? { __data["catchRate"] }
      /// The colour of a Pokémon as listed in the Pokedex
      public var color: String { __data["color"] }
      /// The egg groups a Pokémon is in
      public var eggGroups: [String]? { __data["eggGroups"] }
      /// EV yields for a Pokémon
      public var evYields: EvYields { __data["evYields"] }
      /// The evolution level, or special method, for a Pokémon
      public var evolutionLevel: String? { __data["evolutionLevel"] }
      /// The flavor texts for a Pokémon
      public var flavorTexts: [FlavorText] { __data["flavorTexts"] }
      /// The gender data for a Pokémon
      public var gender: Gender { __data["gender"] }
      /// The height of a Pokémon in meters
      public var height: Double { __data["height"] }
      /// The dex number for a Pokémon
      public var num: Int { __data["num"] }
      /// The preevolutions for a Pokémon, if any
      public var preevolutions: [Preevolution]? { __data["preevolutions"] }
      /// Serebii page for a Pokémon
      public var serebiiPage: String { __data["serebiiPage"] }
      /// The shiny back sprite for a Pokémon. For most Pokémon this will be the animated gif, with some exceptions that were older-gen exclusive
      public var shinyBackSprite: String { __data["shinyBackSprite"] }
      /// The shiny sprite for a Pokémon. For most Pokémon this will be the animated gif, with some exceptions that were older-gen exclusive
      public var shinySprite: String { __data["shinySprite"] }
      /// Smogon page for a Pokémon
      public var smogonPage: String { __data["smogonPage"] }
      /// The smogon tier a Pokémon falls under
      public var smogonTier: String { __data["smogonTier"] }
      /// The species name for a Pokémon
      public var species: String { __data["species"] }
      /// The sprite for a Pokémon. For most Pokémon this will be the animated gif, with some exceptions that were older-gen exclusive
      public var sprite: String { __data["sprite"] }
      /// The types for a Pokémon
      public var types: [Type_SelectionSet] { __data["types"] }
      /// The weight of a Pokémon in kilograms
      public var weight: Double { __data["weight"] }

      /// GetPokemonByDexNumber.Abilities
      ///
      /// Parent Type: `Abilities`
      public struct Abilities: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Abilities }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("first", First.self),
          .field("second", Second?.self),
          .field("hidden", Hidden?.self),
        ] }

        /// The first ability of a Pokémon
        public var first: First { __data["first"] }
        /// The second ability of a Pokémon
        public var second: Second? { __data["second"] }
        /// The hidden ability of a Pokémon
        public var hidden: Hidden? { __data["hidden"] }

        /// GetPokemonByDexNumber.Abilities.First
        ///
        /// Parent Type: `Ability`
        public struct First: PkmnApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Ability }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("shortDesc", String.self),
            .field("desc", String?.self),
            .field("serebiiPage", String.self),
            .field("smogonPage", String.self),
          ] }

          /// The name for an ability
          public var name: String { __data["name"] }
          /// The short description for an ability
          public var shortDesc: String { __data["shortDesc"] }
          /// The long description for an ability
          public var desc: String? { __data["desc"] }
          /// Serebii page for an ability
          public var serebiiPage: String { __data["serebiiPage"] }
          /// Smogon page for an ability
          public var smogonPage: String { __data["smogonPage"] }
        }

        /// GetPokemonByDexNumber.Abilities.Second
        ///
        /// Parent Type: `Ability`
        public struct Second: PkmnApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Ability }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("shortDesc", String.self),
            .field("desc", String?.self),
            .field("serebiiPage", String.self),
            .field("smogonPage", String.self),
          ] }

          /// The name for an ability
          public var name: String { __data["name"] }
          /// The short description for an ability
          public var shortDesc: String { __data["shortDesc"] }
          /// The long description for an ability
          public var desc: String? { __data["desc"] }
          /// Serebii page for an ability
          public var serebiiPage: String { __data["serebiiPage"] }
          /// Smogon page for an ability
          public var smogonPage: String { __data["smogonPage"] }
        }

        /// GetPokemonByDexNumber.Abilities.Hidden
        ///
        /// Parent Type: `Ability`
        public struct Hidden: PkmnApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Ability }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("shortDesc", String.self),
            .field("desc", String?.self),
            .field("serebiiPage", String.self),
            .field("smogonPage", String.self),
          ] }

          /// The name for an ability
          public var name: String { __data["name"] }
          /// The short description for an ability
          public var shortDesc: String { __data["shortDesc"] }
          /// The long description for an ability
          public var desc: String? { __data["desc"] }
          /// Serebii page for an ability
          public var serebiiPage: String { __data["serebiiPage"] }
          /// Smogon page for an ability
          public var smogonPage: String { __data["smogonPage"] }
        }
      }

      /// GetPokemonByDexNumber.BaseStats
      ///
      /// Parent Type: `Stats`
      public struct BaseStats: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Stats }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("attack", Int.self),
          .field("defense", Int.self),
          .field("hp", Int.self),
          .field("specialattack", Int.self),
          .field("specialdefense", Int.self),
          .field("speed", Int.self),
        ] }

        /// The base attack stat of a Pokémon
        public var attack: Int { __data["attack"] }
        /// The base defense stat of a Pokémon
        public var defense: Int { __data["defense"] }
        /// The base HP stat of a pokémon
        public var hp: Int { __data["hp"] }
        /// The base special attack stat of a Pokémon
        public var specialattack: Int { __data["specialattack"] }
        /// The base special defense stat of a Pokémon
        public var specialdefense: Int { __data["specialdefense"] }
        /// The base speed stat of a Pokémon
        public var speed: Int { __data["speed"] }
      }

      /// GetPokemonByDexNumber.CatchRate
      ///
      /// Parent Type: `CatchRate`
      public struct CatchRate: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.CatchRate }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("base", Int.self),
          .field("percentageWithOrdinaryPokeballAtFullHealth", String.self),
        ] }

        /// The base catch rate for a Pokémon that will be used to calculate the final catch rate
        public var base: Int { __data["base"] }
        /// The chance to capture a Pokémon when an ordinary Poké Ball is thrown at full health without any status condition
        public var percentageWithOrdinaryPokeballAtFullHealth: String { __data["percentageWithOrdinaryPokeballAtFullHealth"] }
      }

      /// GetPokemonByDexNumber.EvYields
      ///
      /// Parent Type: `EvYields`
      public struct EvYields: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.EvYields }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("attack", Int.self),
          .field("defense", Int.self),
          .field("hp", Int.self),
          .field("specialattack", Int.self),
          .field("specialdefense", Int.self),
          .field("speed", Int.self),
        ] }

        /// The attack EV yield of a Pokémon
        public var attack: Int { __data["attack"] }
        /// The defense EV yield of a Pokémon
        public var defense: Int { __data["defense"] }
        /// The HP EV yield of a pokémon
        public var hp: Int { __data["hp"] }
        /// The special attack EV yield of a Pokémon
        public var specialattack: Int { __data["specialattack"] }
        /// The special defense EV yield of a Pokémon
        public var specialdefense: Int { __data["specialdefense"] }
        /// The speed EV yield of a Pokémon
        public var speed: Int { __data["speed"] }
      }

      /// GetPokemonByDexNumber.FlavorText
      ///
      /// Parent Type: `Flavor`
      public struct FlavorText: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Flavor }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("flavor", String.self),
          .field("game", String.self),
        ] }

        /// The flavor text for this entry
        public var flavor: String { __data["flavor"] }
        /// The name of the game this flavor text is from
        public var game: String { __data["game"] }
      }

      /// GetPokemonByDexNumber.Gender
      ///
      /// Parent Type: `Gender`
      public struct Gender: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Gender }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("female", String.self),
          .field("male", String.self),
        ] }

        /// The percentage for female occurrences
        public var female: String { __data["female"] }
        /// The percentage of male occurrences
        public var male: String { __data["male"] }
      }

      /// GetPokemonByDexNumber.Preevolution
      ///
      /// Parent Type: `Pokemon`
      public struct Preevolution: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.Pokemon }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("species", String.self),
        ] }

        /// The species name for a Pokémon
        public var species: String { __data["species"] }
      }

      /// GetPokemonByDexNumber.Type_SelectionSet
      ///
      /// Parent Type: `PokemonType`
      public struct Type_SelectionSet: PkmnApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PkmnApi.Objects.PokemonType }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        /// The name of the typ
        public var name: String { __data["name"] }
      }
    }
  }
}
