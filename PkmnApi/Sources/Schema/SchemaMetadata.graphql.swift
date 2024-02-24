// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == PkmnApi.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == PkmnApi.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == PkmnApi.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == PkmnApi.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return PkmnApi.Objects.Query
    case "Pokemon": return PkmnApi.Objects.Pokemon
    case "Abilities": return PkmnApi.Objects.Abilities
    case "Ability": return PkmnApi.Objects.Ability
    case "Stats": return PkmnApi.Objects.Stats
    case "CatchRate": return PkmnApi.Objects.CatchRate
    case "EvYields": return PkmnApi.Objects.EvYields
    case "Flavor": return PkmnApi.Objects.Flavor
    case "Gender": return PkmnApi.Objects.Gender
    case "PokemonType": return PkmnApi.Objects.PokemonType
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
