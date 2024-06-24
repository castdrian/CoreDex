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
        case "Query": PkmnApi.Objects.Query
        case "Pokemon": PkmnApi.Objects.Pokemon
        case "Abilities": PkmnApi.Objects.Abilities
        case "Ability": PkmnApi.Objects.Ability
        case "Stats": PkmnApi.Objects.Stats
        case "CatchRate": PkmnApi.Objects.CatchRate
        case "EvYields": PkmnApi.Objects.EvYields
        case "Flavor": PkmnApi.Objects.Flavor
        case "Gender": PkmnApi.Objects.Gender
        case "PokemonType": PkmnApi.Objects.PokemonType
        default: nil
        }
    }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
