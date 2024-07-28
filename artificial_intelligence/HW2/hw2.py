import numpy as np
import copy
import os
import random
import shutil
import cv2

IMAGE_WIDTH = 0
IMAGE_HEIGHT = 0
IMAGE_PATH = "painting.png"


class Member:
    def __init__(self, num_genes, identity=-2, fitness=0, components=[]):
        self.identity = identity
        
        self.fitness = fitness
        self.components = components
        if len(components) == 0:
            for i in range(num_genes):
                self.components.append(Component(i))

            self.components.sort(key=lambda x: x.size, reverse=True)

    def visualize(self):
        image = np.full((IMAGE_WIDTH, IMAGE_HEIGHT, 3), 255, np.uint8)

        for component in self.components:
            overlay = image.copy()
            color = (component.red, component.green, component.blue)
            cv2.circle(overlay, (component.x, component.y), component.size, color, -1)
            image = cv2.addWeighted(overlay, component.transparency, image, 1 - component.transparency, 0, image)

        return image

    def assess(self):
        source = cv2.imread(IMAGE_PATH)
        source_np = np.array(source, dtype=np.int64)

        picture = self.visualize()
        picture_np = np.array(picture, dtype=np.int64)

        difference = np.subtract(source_np, picture_np)
        squared_diff = np.square(difference)
        self.fitness = -np.sum(squared_diff)
        return self.fitness

    def mutate(self, mutation_style, mutation_probability):
        mutations = []
        while random.random() < mutation_probability:
            random_component_id = random.randint(0, len(self.components) - 1)

            if len(mutations) >= len(self.components):
                return

            while random_component_id in mutations:
                random_component_id = random.randint(0, len(self.components) - 1)

            mutations.append(random_component_id)
            if mutation_style == "random":
                self.components[random.randint(0, len(self.components) - 1)] = Component(id=random_component_id)
            elif mutation_style == "guided":
                self.components[random_component_id].guide_mutation()


class Component:
    def __init__(self, id=-2):
        self.id = id
        self.size = random.randint(1, max(IMAGE_WIDTH, IMAGE_HEIGHT) // 2)
        self.x, self.y = self.calculate_coordinates()
        self.red = random.randint(0, 255)
        self.green = random.randint(0, 255)
        self.blue = random.randint(0, 255)
        self.transparency = random.random()

    def calculate_coordinates(self, guided=False):
        while True:
            if guided:
                x = self.x + random.randint(-IMAGE_WIDTH // 4, IMAGE_WIDTH // 4)
                y = self.y + random.randint(-IMAGE_HEIGHT // 4, IMAGE_HEIGHT // 4)
            else:
                x = random.randint(IMAGE_WIDTH * -1.6, IMAGE_WIDTH * 1.6)
                y = random.randint(IMAGE_HEIGHT * -1.6, IMAGE_HEIGHT * 1.6)

            if self.validate_circle(x, y):
                return x, y  

    def guide_mutation(self):
        self.size = np.clip(
            self.size + random.randint(-10, 10), 1, min(IMAGE_WIDTH, IMAGE_HEIGHT) // 2
        )

        self.x, self.y = self.calculate_coordinates(guided=True)

        self.red = int(np.clip(self.red + random.randint(-64, 64), 0, 255))
        self.green = int(np.clip(self.green + random.randint(-64, 64), 0, 255))
        self.blue = int(np.clip(self.blue + random.randint(-64, 64), 0, 255))
        self.transparency = np.clip(self.transparency + random.uniform(-0.25, 0.25), 0, 1)

    def validate_circle(self, x, y):
        if x - self.size >= IMAGE_WIDTH or x + self.size < 0:
            return False
        if y - self.size >= IMAGE_HEIGHT or y + self.size < 0:
            return False
        if x - self.size < 0 or x + self.size >= IMAGE_WIDTH:
            return True
        if y - self.size < 0 or y + self.size >= IMAGE_HEIGHT:
            return True
        if x - self.size >= 0 and x + self.size < IMAGE_WIDTH:
            return True
        
        if y - self.size >= 0 and y + self.size < IMAGE_HEIGHT:
            return True

        return False


class Population:
    def __init__(self, num_individuals, num_genes, population=[]):
        self.population = population
        self.best_population = []

        if len(population) == 0:
            for i in range(num_individuals):
                self.population.append(Member(identity=i, num_genes=num_genes))

    def evaluate(self):
        for individual in self.population:
            individual.assess()

    def sort_population(self):
        t = sorted(self.population, key=lambda x: x.fitness, reverse=True)
        return t

    def sort_individuals(self, pop):
        return sorted(pop, key=lambda x: x.fitness, reverse=True)

    def select_parents(self, elite_fraction, parent_fraction, tournament_size):
        self.population = self.sort_population()
        num_parents = int(len(self.population) * parent_fraction)
        num_elites = int(len(self.population) * elite_fraction)
        

        if num_parents % 2== 1:
            num_parents+= 1

        elites = self.population[:num_elites]
        non_elites = self.population[num_elites:]

        parents = []
        for i in range(num_parents):
            tournament = random.sample(non_elites, min(tournament_size, len(non_elites)))
            best = self.sort_individuals(tournament)[0]

            parents.append(best)
            non_elites.remove(best)

        return elites, non_elites, parents

    def recombine(self, parents, num_genes):
        children = []
        for i in range(0, len(parents), 2):
           
            parent2 = parents[i + 1]
            parent1 = parents[i]

            child_components1= []
            child_components2= []

            for j in range(len(parent1.components)):
                if random.random() >= 0.5:
                    child_components1.append(copy.deepcopy(parent1.components[j]))

                    child_components2.append(copy.deepcopy(parent2.components[j]))
                else:
                    child_components1.append(copy.deepcopy(parent2.components[j]))

                    child_components2.append(copy.deepcopy(parent1.components[j]))

            
            child2 = Member(num_genes=num_genes, components=child_components2)
            child1 = Member(num_genes=num_genes, components=child_components1)
            child1.assess()
            child2.assess()

            pop = self.sort_individuals([child1, child2, parent1, parent2])
            children.append(pop[0])
            children.append(pop[1])

        return children

def save_results(population, name, generation, path, best_individual, image_only=True):
    print(best_individual.fitness)

    current_name = f"{name}_{generation}"
    file_path = f"{path}{current_name}"
    

    cv2.imwrite(f"{path}{current_name}.png", best_individual.visualize())

def evolutionary_algorithm(
    name,
    num_generations=10000,
    num_individuals=20,
    num_genes=50,
    tournament_size=5,

    mutation_style="guided",

    elite_fraction=0.2,

    parent_fraction=0.6,
    mutation_probability=0.2,
):
    path = f"outcomes/{name}/"

    if os.path.exists(path):
        shutil.rmtree(path)

    if not os.path.exists(path):
        os.mkdir(path)

    pop = Population(num_individuals, num_genes)

    for generation in range(num_generations):

        pop.evaluate()

        elites, non_elites, parents = pop.select_parents(

            elite_fraction, parent_fraction, tournament_size
        )

        children= pop.recombine(parents, num_genes)

        for individual in non_elites + children:

            individual.mutate(mutation_style, mutation_probability)

        pop.population = elites + children + non_elites

        sorted_population= pop.sort_population()

        pop.best_population.append(sorted_population[0])

        if generation % 1000== 0 or generation == 0:
            save_results(pop, name, generation, path, sorted_population[0])

        if generation % 100== 0:
            print(
                "Generation:",      generation,   "fitness:",   sorted_population[0].fitness,
            )

    pop.evaluate()
    sorted_population = pop.sort_population()
    pop.best_population.append(sorted_population[0])
    save_results(pop, name, 10000, path, sorted_population[0], image_only=False)

if __name__ == "__main__":
    img = cv2.imread(IMAGE_PATH)
    IMAGE_WIDTH= img.shape[0]
    IMAGE_HEIGHT= img.shape[1]

    IMAGE_RADIUS= (IMAGE_WIDTH + IMAGE_HEIGHT) / 2

    evolutionary_algorithm(name="baseline")

    
    evolutionary_algorithm(name="population_size_40", num_individuals=20)

    evolutionary_algorithm(name="gene_count_80", num_genes=50)

    evolutionary_algorithm(name="tournament_size_8", tournament_size=8)

    evolutionary_algorithm(name="elite_fraction_0.35", elite_fraction=0.35)

    evolutionary_algorithm(name="parent_fraction_0.75", parent_fraction=0.6)

    evolutionary_algorithm(name="mutation_probability_0.4", mutation_probability=0.4)

    evolutionary_algorithm(name="mutation_style_random", mutation_style="random")
