//
//  Mapper.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 29/02/24.
//

import Foundation

protocol DomainEntityMapper {
    associatedtype DTO
    associatedtype DomainEntity
    func mapToDomain(_ dto: DTO) -> DomainEntity
}
